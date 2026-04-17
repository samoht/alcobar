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
  times and writes the exact bytes consumed by generators to `DIR/seed_NNN`.
  Use these to seed `afl-fuzz`.

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
