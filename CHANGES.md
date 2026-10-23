## v0.4.0 (23/10/2026)

- Drop OCaml 4.08 to 4.10, which opam-repository no longer carries: alcobar
  now requires OCaml 4.11 or later (#4, @samoht)
- Add `test_case ~outcomes` and `reach`: name the cases a property must
  exercise, see how often each was hit, and fail when one never is, so a
  generator that silently stops covering a case is caught (@samoht)
- Add `verdict`, a check over the whole campaign (such as "every outcome was
  reached") run once after all properties; AFL never feeds it inputs, so a
  campaign-wide check no longer turns into a fuzzing crash (#3, @samoht)
- Fix `--gen-corpus` for suites with several tests: each seed now replays the
  test it was made for, so `afl-cmin` accepts the corpus instead of reporting
  "No instrumentation detected" (#3, @samoht)

## v0.3.2 (20/08/2026)

- Fail a property whose guard rejected every generated input, instead of
  reporting a pass (#1, @samoht)
- Report which tests `--gen-corpus` came up short on, and fail when no test
  could be seeded at all, instead of printing a count that reads like a
  complete corpus (@samoht)
- Take the `calendar` example out of `dune runtest`: the property it
  demonstrates finds a genuine bug in `calendar`, which about half of all
  seeds hit, so the release failed opam CI on the compilers whose default
  seed found it (@samoht)
- Run CI on 4.08 and 4.14 as well as 5.4 (@samoht)

## v0.3.1 (21/04/2026)

Fork of Crowbar, renamed to Alcobar.

- New upstream: `samoht/alcobar` (maintainer: Thomas Gazagnaire).
- Adopt `ocamlformat` (version 0.29.0).
- Alcotest-compatible API: `test_case` and `run` replace the old
  `add_test` interface; property tests run via `Alcotest.run_with_args`,
  AFL mode is preserved by detecting a file argument. Examples now build
  as executables with an explicit `runtest` rule, so test binaries can
  be invoked directly with CLI flags.
- `--gen-corpus DIR` flag generates seed corpus files from passing
  test runs, capturing the exact bytes consumed by generators.
- Per-test timeout (`ALCOBAR_TIMEOUT` env var, `--timeout` flag);
  defaults to 2 seconds. Use `--timeout 0` to disable.
- Per-test time budget (`--budget SECONDS`); iteration stops when the
  budget is exhausted. Defaults to 2 seconds. Use `--budget 0` to disable.
- README rewritten for the alcobar fork.
- GitHub Actions CI on push and pull request.
- Library sources moved from `src/` to `lib/`.
- Restructure examples as fuzz runners: each directory has `fuzz.ml`
  plus a `fuzz_<lib>.ml[i]` module exporting a `suite` value.
- Require dune >= 3.21 and use `%{dune-warnings}` for dev flags.

v0.2.1 (04 March 2022)
---------------------

Build and compatibility fixes.

v0.2 (04 May 2020)
---------------------

New generators, printers and port to dune.

v0.1 (01 February 2018)
---------------------

Initial release
