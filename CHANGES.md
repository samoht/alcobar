## v0.3 (unreleased)

Fork of Crowbar, renamed to Alcobar.

- Alcotest-compatible API: `test_case`, `run`, and suite exports
  replace the old `add_test`/`run_test` interface.
- `--gen-corpus DIR` flag to generate seed corpus files from passing
  test runs, removing the need for a separate `gen_corpus.ml`.
- Per-test timeout (`ALCOBAR_TIMEOUT` env var, `--timeout` flag).
- Per-test time budget (`--budget` flag).
- GitHub Actions CI.

## v0.2.1 (04 March 2022)

Build and compatibility fixes.

## v0.2 (04 May 2020)

New generators, printers and port to dune.

## v0.1 (01 February 2018)

Initial release
