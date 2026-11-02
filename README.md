# Alcobar

**Alcobar** is Crowbar with an [Alcotest](https://github.com/mirage/alcotest)-compatible
API. Like Crowbar, it combines QuickCheck-style property-based testing with the
bug-finding powers of [afl-fuzz](http://lcamtuf.coredump.cx/afl/). Unlike Crowbar,
it surfaces tests as Alcotest test cases, so they integrate with the rest of an
Alcotest suite.

See [`examples/`](./examples) for full native test programs. This monorepo
imports the exact installed Alcobar source so it is rebuilt against the same
Alcotest library as all callers. The deliberately failing external Calendar
demo and already-disabled xmldiff demo are outside this package scope; active
Alcobar outcome, replay, campaign and generator fixtures remain enabled.

## Writing tests

A test is a value of type `test_case`, grouped into suites, and run via `run`:

<!-- $MDX file=examples/readme/main.ml -->
```ocaml
open Alcobar

let identity = test_case "identity" [ int ] (fun x -> check_eq x x)
let () = run "my_lib" [ ("arith", [ identity ]) ]
```

Run the native program with a fixed seed and sample count:

```sh
$ ./examples/readme/main.exe --seed 1 --repeat 100 --budget 0 --color=never > identity.out
$ grep -F -c '[OK]' identity.out
1
```


This mirrors [`Alcotest.run`](https://mirage.github.io/alcotest): the first
argument names the run, the second is a list of `(suite_name, tests)` pairs.

## Naming the outcomes a property reaches

A property that returns `()` on every branch passes whether or not its
samples ever take the branch that checks something. A roundtrip test over a
decoder that refuses every generated input is green and tests nothing. A
test case can name its outcomes, and the property reports the one each
sample reaches with `reach`:

<!-- $MDX file=examples/outcomes/covered.ml -->
```ocaml
open Alcobar

(* Every sample reaches "always", twice: the count is of samples, so a run of
   N samples reports N, and a runner that counted calls would report 2N. Half
   the samples are even, so "even" and "odd" are both reached in any run of a
   hundred samples. The [runtest] rule beside this reads the counts the run
   prints. *)
let parity n =
  reach "always";
  reach (if n land 1 = 0 then "even" else "odd");
  reach "always"

let suite =
  ( "outcomes",
    [ test_case ~outcomes:[ "always"; "even"; "odd" ] "parity" [ int ] parity ]
  )

let () = run "covered" [ suite ]
```

Here a sample reaches `always` twice, but the count records passing samples,
not calls to `reach`. The fixed run reports one hundred:

```sh
$ ./examples/outcomes/covered.exe --seed 1 --repeat 100 --budget 0 --color=never > outcomes.out
$ grep -F -c 'outcomes/parity: 100 samples: always 100, even ' outcomes.out
1
```


A property run counts the passing samples that reached each outcome, prints
the counts after the Alcotest report, and fails the test when an outcome was
reached by no passing sample:

```
Outcomes reached:
  outcomes/parity: 100 samples: always 100, even 53, odd 47
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

## Relation to Crowbar

Alcobar is a fork of [stedolan/crowbar](https://github.com/stedolan/crowbar).
The generator API (`int`, `map`, `choose`, `fix`, `dynamic_bind`, ...) is
unchanged. The testing API is different: `add_test` is replaced by `test_case`
and an explicit `run`, and the runner embeds an Alcotest suite rather than
invoking Cmdliner directly.
