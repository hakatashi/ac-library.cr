# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `TwoSat#answer` no longer requires calling `#satisfiable?` beforehand. It solves the formula on demand, and re-solves it if clauses were added after the last solve.
- `ModInt#**` (Montgomery implementation for 998244353 / 1000000007) now returns early for a zero base, as originally intended. The result is unchanged.
- Remove a duplicated private `log2_ceil` definition in `SegTree`.

### Documentation

- README: Fix the Crystal counterpart of `two_sat` (`AtCoder::TwoSat.new(n)`) and a typo in the `atcoder/scc` heading.
- Fix doc comments of `SegTree#all_prod`, `SegTree#max_right`, `SegTree#min_left`, `LazySegTree#set` and `static_modint`.

- README: Document that `SegTree` uses the maximum as the default operation.

### Changed

- CI: Run tests on Crystal 1.17.0 (the version on the AtCoder judge) and the latest Crystal.
- CI: Replace container-based jobs with `crystal-lang/install-crystal`, and update deprecated actions (`actions/cache@v2`, Codecov bash uploader, etc.).
- Development dependencies: Update ameba to 1.6.4 and cr-bundle to the latest commit.

## [0.1.0] - 2023-11-28

The version adopted by the AtCoder 2025-10 language update (Crystal 1.17.0, commit `c57c18d`).

[Unreleased]: https://github.com/hakatashi/ac-library.cr/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hakatashi/ac-library.cr/releases/tag/v0.1.0
