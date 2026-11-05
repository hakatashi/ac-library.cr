# AGENTS.md

Guidance for coding agents (and humans) working on **ac-library.cr**, a Crystal port of
[AtCoder Library (ACL)](https://github.com/atcoder/ac-library).

## Project context

- The library is installed on the **AtCoder judge** (2025-10 language update, Crystal 1.17.0),
  pinned to tag `v0.1.0` (commit `c57c18d`). Changes on `master` reach contestants only when a
  future language update adopts a newer release. Users also write code locally against `master`,
  so **behavior on the judge and locally can diverge** — keep this in mind for every change.
- The project is in low-maintenance mode. The goal is to fill known gaps (see GitHub issues)
  so that a better release can be adopted by the next AtCoder language update.
- Supported Crystal versions: **1.17.0 (judge) and the latest release**. Both are tested in CI.

## Compatibility policy (while the version is 0.x)

1. **Never remove or rename** public classes, modules, methods, or `require` paths
   (`atcoder`, `atcoder/<file>`). Contestants already depend on them. Add aliases instead.
2. **Breaking changes to behavior/implementation are allowed** only after weighing the impact on
   contestants who already use the library. Record every such change in `CHANGELOG.md`
   (and in the issue/PR description).
3. Existing API asymmetries are kept as-is for compatibility (see "Known intentional
   asymmetries" below). Do not "fix" them.

## Repository layout

| Path | Contents |
|---|---|
| `src/*.cr` | Library. One file per ACL header (snake_case), plus non-ACL extras. `src/atcoder.cr` requires everything. |
| `spec/*_spec.cr` | Unit specs (`crystal spec`). `spec/spec_helper.cr` defines `ModInt7` and `alias Mint`. `spec/test_runner.cr` (`require "./*"`) is the entry point for the kcov coverage build (`shards build test`). |
| `verify/*.test.cr` | [online-judge-verify-helper](https://github.com/online-judge-tools/verification-helper) tests against Library Checker / AOJ. |
| `benchmarks/*.cr` | `Benchmark.bm` benchmarks, run in CI (no thresholds). File names are CamelCase for historical reasons. |
| `.verify-helper/` | oj-verify config. `build.sh` compiles, `bin/cr-bundle` bundles. |
| `.github/workflows/test.yml` | CI: test (1.17.0 + latest), coverage, lint, verify, deploy (GitHub Pages: `/api/` = `crystal docs`, `/docs/` = oj-verify docs). |

## Commands

```bash
crystal spec                      # unit tests
shards install && bin/ameba       # lint (ameba 1.6.x)
crystal run --release benchmarks/*
pip install -r requirements.txt && oj-verify run verify/<problem>.test.cr   # needs Python, g++
```

Run `crystal spec` and `bin/ameba` before every commit. When touching an algorithm, also run the
relevant `verify/` file(s).

## How ACL is re-designed for Crystal

### Naming and namespaces

- Everything lives under `module AtCoder`. Class names are ACL names in CamelCase
  (`fenwick_tree` → `FenwickTree`, `lazy_segtree` → `LazySegTree`, `dsu` → `DSU`, `scc` → `SCC`,
  `mf_graph` → `MaxFlow`, `mcf_graph` → `MinCostFlow`, `two_sat` → `TwoSat`).
- Free functions become module functions (`def self.xxx`) on a module named after the ACL header:
  `AtCoder::Math`, `AtCoder::Convolution`, `AtCoder::String`. Note that `AtCoder::String` /
  `AtCoder::Math` shadow the stdlib inside `module AtCoder`; write `::String` / `::Math` there.
- File names are snake_case and match the ACL header (`lazy_seg_tree.cr`, `mod_int.cr`).

### Idiomatic Crystal API, with ACL names kept as aliases

- Getting / range product → `#[]`; setting → `#[]=`; ranges are `Range` objects.
  e.g. `segtree.prod(l, r)` → `tree[l...r]`, `segtree.set(p, x)` → `tree[p] = x`.
- ACL-named methods are kept as compatibility aliases where they exist
  (`SegTree#set/#get/#prod`, `ModInt#pow/#val`), marked with `# compatibility with ac-library`.
- Predicates end with `?` (`DSU#same?`, `TwoSat#satisfiable?`, `Int#prime?`).
- Ranges support open ends (`tree[..3]`, `tree[1..]`, `tree[...]`) using this idiom:

  ```crystal
  l = range.begin || 0
  r = range.exclusive? ? (range.end || size) : (range.end || size - 1) + 1
  ```

### Identity elements are implicit `nil`

- `SegTree` / `LazySegTree` do not take ACL's `e()` / `id()`. Internally they store `T | Nil` and
  treat `nil` as the identity (and as the identity mapping for `LazySegTree`). Consequently
  `nil` cannot be an element of the monoid. Keep this design.
- `max_right` / `min_left` take an optional `e = nil`; without it, `f(e)` is assumed `true`.

### Integer types

- **Public APIs use `Int64` by default** (sizes, indices, capacities, costs, node ids), to prevent
  overflow in contestants' code. Arguments are usually accepted untyped and converted with
  `.to_i64` internally.
- **`Int32` is used internally where it is measurably faster and the spec allows it**
  (e.g. `SegTree`/`LazySegTree` tree indices, `AtCoder::String` algorithms). Document such
  choices with a comment.
- Generic element types (`FenwickTree(T)`, `SegTree(T)`, `PriorityQueue(T)`, ...) are preferred
  where ACL is generic. Use `_i64` literal suffixes and `_` digit separators (`1_000_000_007_i64`).

### ModInt

- `AtCoder.static_modint(Name, modulo)` is a macro that defines `struct AtCoder::Name` and
  reopens `struct Int` for mixed arithmetic. `ModInt998244353` and `ModInt1000000007` use a
  Montgomery representation (selected by `{% if %}` on the literal modulus); other moduli use a
  plain `Int64` implementation. Keep both paths' APIs identical.
- Comparison operators (`<`, `>`, ...) intentionally raise `NotImplementedError`.

### Known intentional asymmetries (keep for compatibility)

- `SegTree.new(values) { |a, b| ... }` takes the monoid operation as a **block** (defaulting to
  `max` when omitted) and `[]=` means **set**.
- `LazySegTree.new(values, op, mapping, composition)` takes three **Procs** and `[]=` means
  **apply**; use `#set` to set a value.
- `DSU#groups` returns `Set(Set(Int64))`, `SCC#scc` returns an array of `Set`s.

### Errors

- Invalid arguments: `ArgumentError`. Out-of-range in `max_right`/`min_left`: `IndexError`.
  Unsatisfiable 2-SAT: `TwoSat::NotSatisfiableError`. Division by zero: `DivisionByZeroError`.
- Unimplemented ACL features are stubbed as `# FIXME: Unimplemented` +
  `raise NotImplementedError.new("AtCoder::Xxx#method")` (the argument is required), and listed as "Unimplemented" in README.
- Bounds checks are generally left to `Array` (`IndexError`), except where ACL asserts.

### Class design

- Data structures are `class`es; value types (ModInt, small records) are `struct`s / `record`s.
- Small hot helpers are `private` and marked `@[AlwaysInline]`.
- Every `src` file must compile when required **on its own** (`require "atcoder/<file>"`); add
  explicit `require "./xxx.cr"` (relative path with extension) for every dependency.
- Avoid deep recursion: graph traversals must be iterative (Crystal's frames are large and
  path-shaped inputs with ~10^5–10^6 vertices are common). Prefer arrays over `Hash`/`Set` in
  hot paths.

### Features not in ACL

- `PriorityQueue` and `Prime` (a port of Ruby's `Prime`) are documented in README as "(not in ACL)".
- `RedBlackTree`, `SkewHeap` and `Graph` / `DirectedGraph` / `UndirectedGraph` / `Tree` are
  **experimental**: they are intentionally not documented in README because their quality was
  not confirmed. `Graph`/`Tree` were meant to be general-purpose graph/tree helpers unique to this
  library; they may be documented after they are verified and polished.

## Documentation conventions

- Every source file (src, spec, verify, benchmarks; except `spec/spec_helper.cr` and
  `spec/test_runner.cr`) starts with the Apache-2.0 license header with
  `Copyright 2023 Google LLC`. Copy it verbatim from an existing file into new files. Do not change
  the copyright holder.
- Doc comments:
  - Classes/modules: `# Implements [atcoder::segtree](https://atcoder.github.io/ac-library/master/document_en/segtree.html).`
    followed by a fenced example using `# => ` for results.
  - Methods: `# Implements atcoder::dsu.merge(a, b).`; reuse with `# :ditto:`.
- README is **English only**. Each module has a section:

  ```
  ## [`atcoder/xxx`](https://hakatashi.github.io/ac-library.cr/docs/src/xxx.cr) (Implements [<atcoder/xxx>](https://atcoder.github.io/ac-library/document_en/xxx.html))

  * `acl_constructor(n)` => `AtCoder::Xxx.new(n)`
    * `.acl_method(args)` => `#crystal_method(args)`
    * `.not_yet()` => Unimplemented
  ```

  Explain differences from ACL as bullet notes under the method. Any public API change must update
  README (the PR template has a checkbox for it).
- User-visible changes go into `CHANGELOG.md` under `## [Unreleased]`
  ([Keep a Changelog](https://keepachangelog.com/en/1.1.0/), SemVer).

## Tests

- Specs: `require "../src/xxx.cr"` (+ `./spec_helper.cr` if needed), then `require "spec"`, then
  `alias Xxx = AtCoder::Xxx`. Structure: `describe "Xxx"` → `describe "#instance_method"` /
  `describe ".class_method"` → `it "does something"`. Use `should eq`, `expect_raises`.
- Cover README examples, edge cases (empty input, empty range, open-ended ranges, error cases) and,
  where practical, comparisons against a naive implementation.
- For algorithmic changes, add or run the corresponding `verify/<problem>.test.cr`
  (header: `# verification-helper: PROBLEM <url>`; read input with `read_line.split.map(&.to_i64)`,
  print with `p`/`puts` — `Lint/DebugCalls` is disabled for this reason).
- Benchmarks use `Benchmark.bm` and may assert results with `should eq`.

## Style and workflow

- Follow `crystal tool format` style and keep ameba clean. Disabled rules and their reasons are
  documented in `.ameba.yml`; use inline `# ameba:disable` only with a reason.
- Commit messages: short, imperative, English (e.g. "Add open-ended range test").
- Release flow: update `CHANGELOG.md`, bump `version` in `shard.yml`, then tag `vX.Y.Z` on master.
