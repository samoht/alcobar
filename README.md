# Alcobar

**Alcobar** is Crowbar with an [Alcotest](https://github.com/mirage/alcotest)-compatible
API. Like Crowbar, it combines QuickCheck-style property-based testing with the
bug-finding powers of [afl-fuzz](http://lcamtuf.coredump.cx/afl/). Unlike Crowbar,
it surfaces tests as Alcotest test cases, so they integrate with the rest of an
Alcotest suite.

See [`examples/`](./examples) for full test programs.

## Writing tests

A test is a value of type `test_case`, grouped into suites, and run via `run`:

```ocaml
open Alcobar

let identity =
  test_case "identity" [ int ] (fun x -> check_eq x x)

let () = run "my_lib" [ ("arith", [ identity ]) ]
```

This mirrors [`Alcotest.run`](https://mirage.github.io/alcotest): the first
argument names the run, the second is a list of `(suite_name, tests)` pairs.

## Naming the outcomes a property reaches

A property that returns `()` on every branch passes whether or not its
samples ever take the branch that checks something. A roundtrip test over a
decoder that refuses every generated input is green and tests nothing. A
test case can name its outcomes, and the property reports the one each
sample reaches with `reach`:

```ocaml
let roundtrip buf =
  match Foo.decode buf with
  | Error _ -> reach "refused"
  | Ok v ->
      reach "decoded";
      check_eq (Foo.decode (Foo.encode v)) (Ok v)

let suite =
  ("foo", [ test_case ~outcomes:[ "decoded"; "refused" ] "roundtrip" [ bytes ] roundtrip ])
```

A property run counts the passing samples that reached each outcome, prints
the counts after the Alcotest report, and fails the test when an outcome was
reached by no passing sample:

```
Outcomes reached:
  foo/roundtrip: 5000 samples: decoded 0, refused 5000
```

`reach` with an outcome the test case does not declare fails that sample, so
a misspelt outcome is reported where it is reached.

## Running tests

Every alcobar test binary supports three modes, detected automatically:

- **Alcotest mode (default)**: run as a regular test suite. Supports all of
  Alcotest's CLI flags (filtering, verbose, etc.) as well as:
  - `--seed INT64` — fix the PRNG seed
  - `--repeat N` — iterations per test (default: 5000)
  - `--timeout N` — per-iteration timeout in seconds (default: 2; also reads
    `ALCOBAR_TIMEOUT`)
  - `--budget SECONDS` — total wall-clock budget per test (default: 2)
  - `--infinite` / `-i` — run until a failure is found
  - `--alcobar-verbose` — log each passing iteration

- **Seed corpus mode**: pass `--gen-corpus DIR`. Alcobar runs each test a few
  times and writes to `DIR/seed_NNN` the bytes AFL mode reads to choose that
  test, then the exact bytes its generators consumed, so each seed runs the
  test it was generated for. Use these to seed `afl-fuzz`.

- **AFL mode**: pass a file as the last argument. Alcobar reads from that file
  and drives a single test iteration — the form `afl-fuzz` expects when
  invoked as `afl-fuzz -i in -o out -- ./my_test.exe @@`.

To run under AFL you need a compiler with AFL instrumentation enabled (an
`opam` switch tagged `+afl`). Build a native-code executable, not bytecode.

### Fuzzing with dune and afl-fuzz

Instead of a `+afl` switch, a dune profile can instrument the build. In
`dune-workspace` (or the root `dune` file):

```dune
(env
 (afl
  (ocamlopt_flags (:standard -afl-instrument))))
```

Then give the fuzz executable two rules: a quick property run in
`dune test`, and an `afl-fuzz` campaign under the `afl` profile, seeded by
`--gen-corpus`:

```dune
(executable
 (name fuzz)
 (libraries mylib alcobar))

(rule
 (alias runtest)
 (enabled_if (<> %{profile} afl))
 (action (run %{exe:fuzz.exe})))

(rule
 (alias fuzz)
 (enabled_if (= %{profile} afl))
 (action
  (progn
   (run %{exe:fuzz.exe} --gen-corpus corpus)
   (run afl-fuzz -V 60 -i corpus -o _fuzz -- %{exe:fuzz.exe} @@))))
```

`dune test` runs the properties; `dune build @fuzz --profile afl` fuzzes for
60 seconds (`-V`) and leaves AFL's findings in `_build/default/<dir>/_fuzz`.

## Relation to Crowbar

Alcobar is a fork of [stedolan/crowbar](https://github.com/stedolan/crowbar).
The generator API (`int`, `map`, `choose`, `fix`, `dynamic_bind`, ...) is
unchanged. The testing API is different: `add_test` is replaced by `test_case`
and an explicit `run`, and the runner embeds an Alcotest suite rather than
invoking Cmdliner directly.
