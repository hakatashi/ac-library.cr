# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `AtCoder::DynamicModInt`, which implements ACL's `modint` (`dynamic_modint`), a ModInt whose modulus is set at runtime by `.set_mod`. Multiplication uses Barrett reduction, in the same way as ACL v1.5.1 ([#34](https://github.com/hakatashi/ac-library.cr/issues/34)).
- `.mod` class method of static ModInts (`ModInt998244353.mod`, etc.), which returns the modulus as in ACL's `mint::mod()`.

### Fixed

- `require "atcoder/convolution"` now compiles when required alone without `atcoder/mod_int` or `atcoder/math` ([#29](https://github.com/hakatashi/ac-library.cr/issues/29)). Previously, calling `Convolution.convolution_ll` with only `atcoder/convolution` required failed to compile because `ModInt754974721` was undefined.
- `MaxFlow#flow` no longer overflows the stack on graphs with very long augmenting paths (e.g. a path graph of 200,000 vertices) ([#26](https://github.com/hakatashi/ac-library.cr/issues/26)). The DFS that finds augmenting paths is now iterative instead of recursive. The resulting flow is unchanged.
- `Graph#dfs` is now iterative (using an explicit stack), so `Tree#diameter`, `Tree#lca`, `Tree#dist` and `Tree#on_path?` no longer overflow the stack on deep trees such as a path of 200,000 nodes ([#27](https://github.com/hakatashi/ac-library.cr/issues/27)).
- `Tree#diameter` no longer returns `-1` as the endpoints for a single-node tree or a tree whose edge weights are all zero ([#41](https://github.com/hakatashi/ac-library.cr/issues/41)). The farthest node now starts from the start node of each search, so a single-node tree returns `{0, 0, 0, [-1]}`.
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

- `SCC` is rewritten in the same way as ACL (CSR adjacency and Tarjan's algorithm), and `TwoSat` uses it without building `Set`s ([#28](https://github.com/hakatashi/ac-library.cr/issues/28)). On a random graph with 5×10^5 vertices and edges, `SCC#scc` is about 4 times faster and `TwoSat#satisfiable?` about 10 times faster. The return type of `SCC#scc` (`Array(Set(Int64))`) is unchanged, but the order of vertices inside each `Set` may differ from before.
- `SCC#adjacencies` is now built on every call instead of being stored. `SCC#add_edge` raises `IndexError` for an out-of-range vertex at the time of the call.
- `Graph#dfs`: The block passed to `#dfs` keeps the same arguments, but the children of a node are now visited *after* the block returns, instead of inside `callback.call`. Code placed after `callback.call` in the block therefore runs before the subtree is visited. The visiting order of nodes is unchanged. If `callback` is called more than once, the last value is used.
- **(Behavior change)** `.permutation`, `.combination` and `.repeated_combination` of ModInts now return 0 when `k < 0` or `k > n`, instead of raising `ArgumentError` (`k > n`) or returning a wrong value (`k < 0`). They raise `ArgumentError` when `n < 0`. `.repeated_combination(0, 0)` now returns 1 instead of raising.
- `.combination` of ModInts computes one modular inverse instead of two.
- `MinCostFlow#add_edge` now returns the index of the added edge (as in ACL), instead of the internal edge list.
- `require "atcoder/min_cost_flow"` no longer loads `atcoder/graph` (it loads `atcoder/priority_queue` instead).
- `MinCostFlow#get_edge` and `MinCostFlow#edges` are added as stubs raising `NotImplementedError`, like the other unimplemented ACL methods.
- Add unit specs for `MaxFlow`, `SCC`, `TwoSat` and `Graph` / `Tree`.
- CI: Verify that each `src/*.cr` file can be required on its own ([#29](https://github.com/hakatashi/ac-library.cr/issues/29)).
- CI: Run tests on Crystal 1.17.0 (the version on the AtCoder judge) and the latest Crystal.
- CI: Replace container-based jobs with `crystal-lang/install-crystal`, and update deprecated actions (`actions/cache@v2`, Codecov bash uploader, etc.).
- Development dependencies: Update ameba to 1.6.4 and cr-bundle to the latest commit.

## [0.1.0] - 2023-11-28

The version adopted by the AtCoder 2025-10 language update (Crystal 1.17.0, commit `c57c18d`).

[Unreleased]: https://github.com/hakatashi/ac-library.cr/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hakatashi/ac-library.cr/releases/tag/v0.1.0
