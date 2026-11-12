# Alcobar

Alcobar is a fork of [Crowbar](https://github.com/stedolan/crowbar) whose
tests are [Alcotest](https://github.com/mirage/alcotest) test cases. A test is
a property over generated inputs, as in QuickCheck. Run as a test suite, the
binary draws those inputs from a random generator. Run under
[afl-fuzz](https://github.com/AFLplusplus/AFLplusplus), it draws them from the
bytes the fuzzer supplies, so AFL's coverage feedback steers the search.

The [`examples/`](./examples) directory holds complete test programs.

## Writing tests

A test case names a property and the generators of its arguments. `run`
groups test cases into suites, as `Alcotest.run` does:

```ocaml
open Alcobar

let identity =
  test_case "identity" [ int ] (fun x -> check_eq x x)

let () = run "my_lib" [ ("arith", [ identity ]) ]
```

The first argument of `run` names the run, and the second is a list of
`(suite_name, tests)` pairs.

## Outcomes

A property that returns `()` on every branch passes even if no sample ever
takes the branch that checks something. A roundtrip test over a decoder that
refuses every generated input is green and tests nothing. To catch this, a
test case declares its outcomes, and the property calls `reach` with the one
each sample takes:

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

After the Alcotest report, the run prints how many passing samples reached
each outcome. It fails the test if no passing sample reached one of them:

```
Outcomes reached:
  foo/roundtrip: 5000 samples: decoded 0, refused 5000
```

Calling `reach` with an outcome the test case does not declare fails that
sample, so a misspelt name is reported where it is used.

## Verdicts

Some checks look at the run as a whole: a floor on the number of decoded
samples, or the share of inputs a parser must accept. Such a check cannot be
a test case. Under AFL every test case is offered inputs, and a check over
counters kept across samples would read whatever earlier inputs left behind.
Declare it with `verdict` instead:

```ocaml
let decoded = ref 0

let roundtrip buf =
  match Foo.decode buf with
  | Error _ -> ()
  | Ok v ->
      incr decoded;
      check_eq (Foo.decode (Foo.encode v)) (Ok v)

let enough_decoded () =
  if !decoded < 100 then failf "only %d samples decoded" !decoded

let suite =
  ( "foo",
    [ test_case "roundtrip" [ bytes ] roundtrip; verdict "decoded" enough_decoded ] )
```

An Alcotest run calls each verdict once, after every property, as a test in
a final group named `verdict`. A `fail` or `check` inside it fails that test.
AFL runs and `--gen-corpus` never call a verdict.

## Running tests

A test binary has three modes, chosen from its command line.

**As a test suite**, the default, it takes Alcotest's options (test filters,
`--verbose` and the others) and these:

- `--seed INT64` (`-s`) fixes the random seed.
- `--repeat N` (`-r`) sets the number of samples per test (default 5000).
- `--timeout N` bounds each sample, in seconds (default 2, or the value of
  `ALCOBAR_TIMEOUT`). The bound uses SIGALRM, so on Windows samples run with
  no bound and only `--budget` limits a test.
- `--budget SECONDS` bounds the wall-clock time of each test (default 2).
- `--infinite` (`-i`) runs until a test fails.
- `--alcobar-verbose` logs every passing sample.

**To make a seed corpus**, pass `--gen-corpus DIR`. Alcobar runs each test a
few times and writes one file per run, `DIR/seed_NNN`. A file starts with the
bytes that select its test in AFL mode, followed by the bytes its generators
consumed, so each seed replays the test it came from. The selector is the
test's position in the suite, so regenerate the corpus after you add, remove
or reorder tests.

**Under AFL**, pass an input file as the last argument. Alcobar reads its
input from that file and runs one sample.
`afl-fuzz -i in -o out -- ./my_test.exe @@` calls the binary in this form.
AFL needs a native-code executable built with AFL instrumentation, from an
`opam` switch tagged `+afl` or with the dune profile below.

### Fuzzing with dune

A dune profile can add the instrumentation instead of a `+afl` switch. In
`dune-workspace` or the root `dune` file:

```dune
(env
 (afl
  (ocamlopt_flags (:standard -afl-instrument))))
```

The fuzz executable then gets two rules. The first runs the properties under
`dune test`. The second, under the `afl` profile, writes a seed corpus and
starts `afl-fuzz` on it:

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

`dune build @fuzz --profile afl` then fuzzes for 60 seconds (`-V 60`) and
leaves AFL's findings in `_build/default/<dir>/_fuzz`.

## Differences from Crowbar

The generators (`int`, `map`, `choose`, `fix`, `dynamic_bind` and the rest)
are Crowbar's. Tests are declared with `test_case` and run with an explicit
`run`, where Crowbar has `add_test`, and the runner is an Alcotest suite
instead of a Cmdliner command of its own. Outcomes and verdicts are new in
Alcobar.
