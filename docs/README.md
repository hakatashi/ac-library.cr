# ac-library.cr [![Run test and verifier][ci-badge]][ci-link]

[ci-badge]: https://github.com/google/ac-library.cr/workflows/Run%20test%20and%20verifier/badge.svg
[ci-link]: https://github.com/google/ac-library.cr/actions?query=workflow%3A%22Run+test+and+verifier%22

This is not an officially supported Google product.

ac-library.cr is a Crystal port of [ac-library](https://github.com/atcoder/ac-library).

This library aims to provide the almost-equivalent (and additional) functionality with ac-library but in the manner of Crystal.

## [ModInt.cr](https://google.github.io/ac-library.cr/docs/src/ModInt.cr) ([<atcoder/modint>](https://atcoder.github.io/ac-library/document_en/modint.html))

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

## [FenwickTree.cr](https://google.github.io/ac-library.cr/docs/src/FenwickTree.cr) ([<atcoder/fenwicktree>](https://atcoder.github.io/ac-library/document_en/fenwicktree.html))

* `fenwick_tree<T> fw(n)` => `AtCoder::FenwickTree(T).new(n)`
* `fenwick_tree<T> fw(array)` => `AtCoder::FenwickTree(T).new(array)`

  ```cr
  tree = AtCoder::FenwickTree(Int64).new(10)
  tree.add(3, 10)
  tree.add(5, 20)
  tree[3..5] #=> 30
  tree[3...5] #=> 10
  ```

  * `.add(p, x)` => `#add(p, x)`
  * `.sum(l, r)` => `#[](l...r)`

## [SegTree.cr](https://google.github.io/ac-library.cr/docs/src/SegTree.cr) ([<atcoder/segtree>](https://atcoder.github.io/ac-library/document_en/segtree.html))

* `segtree<S, op, e> seg(v)` => `AtCoder::SegTree(S).new(v, &op?)`

  単位元は暗黙的にnilで定義されるため使用する際に定義する必要はありません。逆に言えばモノイドの (単位元以外の) 元にnilを含めることはできません。 The identity element will be implicitly defined as nil, so you don't have to manually define it. In the other words, you cannot include nil into an element of the monoid.

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

## [LazySegTree.cr](https://google.github.io/ac-library.cr/docs/src/LazySegTree.cr) ([<atcoder/lazysegtree>](https://atcoder.github.io/ac-library/document_en/lazysegtree.html))

* `lazy_segtree<S, op, e, F, mapping, composition, id> seg(v)` => `AtCoder::LazySegTree(S, F).new(v, op, mapping, composition)`

  単位元は暗黙的にnilで定義されるため使用する際に定義する必要はありません。逆に言えばモノイドの (単位元以外の) 元にnilを含めることはできません。 The identity element will be implicitly defined as nil, so you don't have to manually define it. In the other words, you cannot include nil into an element of the monoid.

  また、恒等写像は暗黙的にnilで定義されるため使用する際に定義する必要はありません。逆に言えばFの (恒等写像以外の) 元にnilを含めることはできません。 Similarly, the identity map of F will be implicitly defined as nil, so you don't have to manually define it. In the other words, you cannot include nil into an element of the set F.

  ```cr
  op = ->(a : Int32, b : Int32) { [a, b].min }
  mapping = ->(f : Int32, x : Int32) { f }
  composition = ->(a : Int32, b : Int32) { a }
  tree = AtCoder::LazySegTree(Int32, Int32).new((0...100).to_a, op, mapping, composition)
  tree[10...50] #=> 10
  tree[20...60] = 0
  tree[50...80] #=> 0
  ```

  * `.set(p, x)` => Unimplemented
  * `.get(p)` => `#[](p)`
  * `.prod(l, r)` => `#[](l...r)`
  * `.all_prod()` => `#all_prod`
  * `.apply(p, f)` => `#[]=(p, f)`
  * `.apply(l, r, f)` => `#[]=(l...r, f)`
  * `.max_right<f>(l)` => Unimplemented
  * `.max_left<f>(r)` => Unimplemented

## [DSU.cr](https://google.github.io/ac-library.cr/docs/src/DSU.cr) ([<atcoder/dsu>](https://atcoder.github.io/ac-library/document_en/dsu.html))

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

## [MaxFlow.cr](https://google.github.io/ac-library.cr/docs/src/MaxFlow.cr) ([<atcoder/maxflow>](https://atcoder.github.io/ac-library/document_en/maxflow.html))

* `mf_graph<Cap> graph(n)` => `AtCoder::MaxFlow.new(n)`

  `Cap` is always `Int64`.

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

## [SCC.cr](https://google.github.io/ac-library.cr/docs/src/SCC.cr) ([<atcoder/scc>](https://atcoder.github.io/ac-library/document_en/scc.html))

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

## [TwoSat.cr](https://google.github.io/ac-library.cr/docs/src/TwoSat.cr) ([<atcoder/twosat>](https://atcoder.github.io/ac-library/document_en/twosat.html))

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

## [Math.cr](https://google.github.io/ac-library.cr/docs/src/Math.cr) ([<atcoder/math>](https://atcoder.github.io/ac-library/document_en/math.html))

* `pow_mod(x, n, m)` => `AtCoder::Math.pow_mod(x, n, m)`
* `inv_mod(x, m)` => `AtCoder::Math.inv_mod(x, m)`
* `crt(r, m)` => `AtCoder::Math.crt(r, m)`
* `floor_sum` => `AtCoder::Math.floor_sum(n, m, a, b)`

## [PriorityQueue.cr](https://google.github.io/ac-library.cr/docs/src/PriorityQueue.cr) (not in ACL)

* `AtCoder::PriorityQueue(T).new`

  ```cr
  q = AtCoder::PriorityQueue(Int64).new
  q << 1_i64
  q << 3_i64
  q << 2_i64
  q.pop #=> 3
  q.pop #=> 2
  q.pop #=> 1
  ```

  * `#<<(v : T)`

    Push value into the queue.

  * `#pop`

    Pop value from the queue.

  * `#size`

    Returns size of the queue

## [Prime.cr](https://google.github.io/ac-library.cr/docs/src/Prime.cr) (not in ACL)

* `AtCoder::Prime` (module)

  Implements [Ruby's Prime library](https://ruby-doc.com/stdlib/libdoc/prime/rdoc/Prime.html).

  ```cr
  AtCoder::Prime.first(7) # => [2, 3, 5, 7, 11, 13, 17]
  ```
