# ac-library.cr

This is not an officially supported Google product.

ac-library.cr is a Crystal port of [ac-library](https://github.com/atcoder/ac-library).

This library aims to provide the almost-equivalent (and additional) functionality with ac-library but in the manner of Crystal.

For the convinience of usage in programming contest, each class in the library does not depend on the other files and can be independently used.

## [ModInt.cr](atcoder/ModInt.cr) ([<atcoder/modint>](https://atcoder.github.io/ac-library/document_en/modint.html))

* `modint` => Unimplemented
* `modint998244353` => `AtCoder::ModInt998244353`
* `modint1000000007` => `AtCoder::ModInt1000000007`

  ```cr
  alias Mint = AtCoder::ModInt1000000007
  Mint.new(30_i64) // Mint.new(7_i64) #=> 285714292
  ```

* `static_modint` => `AtCoder.static_modint`

  ```cr
  AtCoder.static_modint(ModInt101, 101_i64)
  alias Mint = AtCoder::ModInt101
  Mint.new(80_i64) + Mint.new(90_i64) #=> 89
  ```

* `dynamic_modint` => Unimplemented

## [FenwickTree.cr](atcoder/FenwickTree.cr) ([<atcoder/fenwicktree>](https://atcoder.github.io/ac-library/document_en/fenwicktree.html))

* `fenwick_tree<T> fw(n)` => `AtCoder::FenwickTree(T).new(n)`

  ```cr
  tree = AtCoder::FenwickTree(Int64).new(10)
  tree.add(3, 10)
  tree.add(5, 20)
  tree[3..5] #=> 30
  tree[3...5] #=> 10
  ```

  * `.add(p, x)` => `#add(p, x)`
  * `.sum(l, r)` => `#[](l...r)`

## [SegTree.cr](atcoder/SegTree.cr) ([<atcoder/segtree>](https://atcoder.github.io/ac-library/document_en/segtree.html))

* `segtree<S, op, e> seg(v)` => `AtCoder::SegTree(S).new(v, &op?)`

  単位元は暗黙的にnilで定義されるため使用する際に定義する必要はありません。逆に言えばモノイドの (単位元以外の) 元にnilを含めることはできません。

  ```cr
  tree = AtCoder::SegTree.new((0...100).to_a) {|a, b| [a, b].min}
  tree[10...50] #=> 10
  ```

  * `.set(p, x)` => `#[]=(p, x)`
  * `.get(p)` => `#[](p)`
  * `.prod(l, r)` => `#[](l...r)`
  * `.all_prod()` => `#all_prod`
  * `.max_right<f>(l)` => Unimplemented
  * `.max_left<f>(r)` => Unimplemented

## [DSU.cr](atcoder/DSU.cr) ([<atcoder/dsu>](https://atcoder.github.io/ac-library/document_en/dsu.html))

* `dsu(n)` => `AtCoder::DSU.new(n)`

  ```cr
  dsu = AtCoder::DSU.new(10)
  dsu.merge(0, 2)
  dsu.merge(4, 2)
  dsu.same(0, 4) #=> true
  dsu.size(4) #=> 3
  ```

  * `.merge(a, b)` => `#merge(a, b)`
  * `.same(a, b)` => `#same(a, b)`
  * `.leader(a)` => `#leader(a)`
  * `.size()` => `#size`
  * `.groups()` => `#groups`

    * This method returns set instead of list.

## [MaxFlow.cr](atcoder/MaxFlow.cr) ([<atcoder/maxflow>](https://atcoder.github.io/ac-library/document_en/maxflow.html))

* `mf_graph<Cap> graph(n)` => `AtCoder::MaxFlow.new(n)`

  `Cap` will be always `Int64`.

  ```cr
  mf = AtCoder::MaxFlow.new(3)
  mf.add_edge(0, 1, 3)
  mf.add_edge(1, 2, 1)
  mf.add_edge(0, 2, 2)
  mf.flow(0, 2) #=> 3
  ```

  * `.add_edge(from, to, cap)` => `#add_edge(from, to, cap)`
  * `.flow(s, t)` => `#flow(s, t)`
  * `.min_cut(s)` => Unimplemented
  * `.get_edge(i)` => Unimplemented
  * `.edges()` => Unimplemented
  * `.change_edge(i, new_cap, new_flow)` => Unimplemented

## [SCC.cr](atcoder/SCC.cr) ([<atcoder/scc>](https://atcoder.github.io/ac-library/document_en/scc.html))

* `scc_graph graph(n)` => `AtCoder::SCC.new(n)`

  ```cr
  scc = AtCoder::SCC.new(3_i64)
  scc.add_edge(0, 1)
  scc.add_edge(1, 0)
  scc.add_edge(2, 0)
  scc.scc #=> [Set{2}, Set{0, 1}]
  ```

  * `.add_edge(from, to)` => `#add_edge(from, to)`
  * `.scc()` => `#scc`

## [TwoSat.cr](atcoder/TwoSat.cr) ([<atcoder/twosat>](https://atcoder.github.io/ac-library/document_en/twosat.html))

* `two_sat graph(n)` => `AtCoder::SCC.new(n)`

  ```cr
  twosat = AtCoder::TwoSat.new(2_i64)
  twosat.add_clause(0, true, 1, false)
  twosat.add_clause(1, true, 0, false)
  twosat.add_clause(0, false, 1, false)
  twosat.satisfiable? #=> true
  twosat.answer #=> [false, false]
  ```

  * `.add_clause(i, f, j, g)` => `#add_clause(i, f, j, g)`
  * `.satisfiable()` => `#satisfiable?`
  * `.answer()` => `#answer`

    This method will raise if it's not satisfiable

