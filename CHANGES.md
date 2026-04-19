## v0.3 (unreleased)

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

v0.2.1 (04 March 2022)
---------------------

Build and compatibility fixes.

v0.2 (04 May 2020)
---------------------

New generators, printers and port to dune.

v0.1 (01 February 2018)
---------------------

Initial release
