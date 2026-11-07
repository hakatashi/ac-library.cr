# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `AtCoder::DynamicModInt`, which implements ACL's `modint` (`dynamic_modint`), a ModInt whose modulus is set at runtime by `.set_mod`. Multiplication uses Barrett reduction, in the same way as ACL v1.5.1 ([#34](https://github.com/hakatashi/ac-library.cr/issues/34)).
- `.mod` class method of static ModInts (`ModInt998244353.mod`, etc.), which returns the modulus as in ACL's `mint::mod()`.

### Fixed

- `MinCostFlow` no longer returns wrong answers when the graph has parallel edges or an edge in the opposite direction of another edge ([#25](https://github.com/hakatashi/ac-library.cr/issues/25)). It is rewritten in the same way as ACL (primal-dual with an adjacency list of edges holding their reverse-edge indices), instead of using `DirectedGraph`, whose adjacency list is a `Hash` keyed by the destination.
- `TwoSat#answer` no longer requires calling `#satisfiable?` beforehand. It solves the formula on demand, and re-solves it if clauses were added after the last solve.
- `ModInt#**` (Montgomery implementation for 998244353 / 1000000007) now returns early for a zero base, as originally intended. The result is unchanged.
- Remove a duplicated private `log2_ceil` definition in `SegTree`.
- The unimplemented `MaxFlow#min_cut`, `#get_edge`, `#edges` and `#change_edge` now raise `NotImplementedError` as intended. Previously, calling them failed to compile.

### Documentation

- README: Fix the Crystal counterpart of `two_sat` (`AtCoder::TwoSat.new(n)`) and a typo in the `atcoder/scc` heading.
- Fix the result of the `static_modint` example in README and the doc comment (`80 + 90` is `69` modulo 101, not `89`).
- Fix doc comments of `SegTree#all_prod`, `SegTree#max_right`, `SegTree#min_left`, `LazySegTree#set` and `static_modint`.

- README: Document that `SegTree` uses the maximum as the default operation.

### Changed

- **(Behavior change)** `.permutation`, `.combination` and `.repeated_combination` of ModInts now return 0 when `k < 0` or `k > n`, instead of raising `ArgumentError` (`k > n`) or returning a wrong value (`k < 0`). They raise `ArgumentError` when `n < 0`. `.repeated_combination(0, 0)` now returns 1 instead of raising.
- `.combination` of ModInts computes one modular inverse instead of two.
- `MinCostFlow#add_edge` now returns the index of the added edge (as in ACL), instead of the internal edge list.
- `require "atcoder/min_cost_flow"` no longer loads `atcoder/graph` (it loads `atcoder/priority_queue` instead).
- `MinCostFlow#get_edge` and `MinCostFlow#edges` are added as stubs raising `NotImplementedError`, like the other unimplemented ACL methods.
- Add unit specs for `MaxFlow`, `SCC`, `TwoSat` and `Graph` / `Tree`.
- CI: Run tests on Crystal 1.17.0 (the version on the AtCoder judge) and the latest Crystal.
- CI: Replace container-based jobs with `crystal-lang/install-crystal`, and update deprecated actions (`actions/cache@v2`, Codecov bash uploader, etc.).
- Development dependencies: Update ameba to 1.6.4 and cr-bundle to the latest commit.

## [0.1.0] - 2023-11-28

The version adopted by the AtCoder 2025-10 language update (Crystal 1.17.0, commit `c57c18d`).

[Unreleased]: https://github.com/hakatashi/ac-library.cr/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hakatashi/ac-library.cr/releases/tag/v0.1.0
