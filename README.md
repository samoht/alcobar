# Alcobar

**Alcobar** is [Crowbar](https://github.com/stedolan/crowbar) with an
[Alcotest](https://github.com/mirage/alcotest)-compatible API.

It is a library for testing code, combining QuickCheck-style property-based
testing and the magical bug-finding powers of
[afl-fuzz](http://lcamtuf.coredump.cx/afl/).

## Writing tests

Tests are organized into suites using an Alcotest-style API. Each test case
takes a list of generators and a property to check:

```ocaml
open Alcobar

let suite =
  ("my_module",
   [
     test_case "roundtrip" [bytes] (fun input ->
       let encoded = My_module.encode input in
       let decoded = My_module.decode encoded in
       check_eq ~pp:pp_string input decoded);

     test_case "no crash" [bytes; int] (fun input n ->
       ignore (My_module.parse input n));
   ])

let () = run "my_project" [ suite ]
```

See the [examples](./examples) directory for more.

## Project setup

### dune-workspace

Define an `afl` context so you can build with AFL instrumentation:

```
(lang dune 3.0)

(context default)
(context
 (default
  (name afl)))

; in your dune-project or per-context config:
(env
 (afl
  (ocamlopt_flags (:standard -afl-instrument))))
```

### Fuzz directory layout

```
my_package/fuzz/
  dune
  fuzz.ml           -- entry point
  fuzz_foo.ml       -- test suite for module Foo
  fuzz_foo.mli      -- exports: val suite : string * Alcobar.test_case list
  corpus/           -- seed input files (auto-generated)
```

### dune

```
(executable
 (name fuzz)
 (modules fuzz fuzz_foo)
 (libraries my_package alcobar))

(rule
 (alias runtest)
 (enabled_if (<> %{profile} afl))
 (deps fuzz.exe)
 (action
  (run %{exe:fuzz.exe})))

(rule
 (alias fuzz)
 (enabled_if (= %{profile} afl))
 (deps fuzz.exe)
 (action
  (progn
   (run %{exe:fuzz.exe} --gen-corpus corpus)
   (run afl-fuzz -V 60 -i corpus -o _fuzz -- %{exe:fuzz.exe} @@))))
```

### fuzz.ml

```ocaml
let () = Alcobar.run "my_project" [ Fuzz_foo.suite ]
```

### fuzz_foo.mli

```ocaml
val suite : string * Alcobar.test_case list
```

## Running tests

Without AFL (quick property-based testing):

```
dune test
```

Generate seed corpus (uses the test generators to produce valid inputs):

```
./fuzz.exe --gen-corpus corpus/
```

With AFL instrumentation:

```
dune build --context=afl @fuzz
```
