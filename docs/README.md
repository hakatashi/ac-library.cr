# ac-library.cr [![Run test and verifier][ci-badge]][ci-link] [![Coverage][coverage-badge]][coverage-link]

[ci-badge]: https://github.com/google/ac-library.cr/workflows/Run%20test%20and%20verifier/badge.svg
[ci-link]: https://github.com/google/ac-library.cr/actions?query=workflow%3A%22Run+test+and+verifier%22
[coverage-badge]: https://codecov.io/gh/google/ac-library.cr/branch/master/graph/badge.svg
[coverage-link]: https://codecov.io/gh/google/ac-library.cr

This is not an officially supported Google product.

ac-library.cr is a Crystal port of [ac-library](https://github.com/atcoder/ac-library).

This library aims to provide the almost-equivalent (and additional) functionality with ac-library but in the manner of Crystal.

## Installation

Add the following code to your project's `shard.yml`.

```yml
dependencies:
  atcoder:
    github: google/ac-library.cr
    branch: master
```

## Usage

```cr
require "atcoder" # load all libraries
require "atcoder/fenwick_tree" # load FenwickTree
```

## [`atcoder/mod_int`](https://google.github.io/ac-library.cr/docs/src/mod_int.cr) (Implements [<atcoder/modint>](https://atcoder.github.io/ac-library/document_en/modint.html))

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

## [`atcoder/fenwick_tree`](https://google.github.io/ac-library.cr/docs/src/fenwick_tree.cr) (Implements [<atcoder/fenwicktree>](https://atcoder.github.io/ac-library/document_en/fenwicktree.html))

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

## [`atcoder/seg_tree`](https://google.github.io/ac-library.cr/docs/src/seg_tree.cr) (Implements [<atcoder/segtree>](https://atcoder.github.io/ac-library/document_en/segtree.html))

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

## [`atcoder/lazy_seg_tree`](https://google.github.io/ac-library.cr/docs/src/lazy_seg_tree.cr) (Implements [<atcoder/lazysegtree>](https://atcoder.github.io/ac-library/document_en/lazysegtree.html))

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

  * `.set(p, x)` => `#set(p, x)`
  * `.get(p)` => `#[](p)`
  * `.prod(l, r)` => `#[](l...r)`
  * `.all_prod()` => `#all_prod`
  * `.apply(p, f)` => `#[]=(p, f)`
  * `.apply(l, r, f)` => `#[]=(l...r, f)`
  * `.max_right<f>(l)` => `#max_right(l, e = nil, &f)`
    * 明示的に単位元を与えない場合、`f(e: nil) = true` として計算します。If the identity element is not given, it computes as `f(e: nil) = true`.
  * `.min_left<f>(r)` => `#min_left(r, e = nil, &f)`
    * 明示的に単位元を与えない場合、`f(e: nil) = true` として計算します。If the identity element is not given, it computes as `f(e: nil) = true`.

## [`atcoder/string`](https://google.github.io/ac-library.cr/docs/src/string.cr) (Implements [<atcoder/string>](https://atcoder.github.io/ac-library/document_en/string.html))

* `suffix_array(s)` => `AtCoder::String.suffix_array(s)`
* `lcp_array(s)` => `AtCoder::String.lcp_array(s)`
* `z_algorithm(s)` => `AtCoder::String.z_algorithm(s)`

## [`atcoder/dsu`](https://google.github.io/ac-library.cr/docs/src/dsu.cr) (Implements [<atcoder/dsu>](https://atcoder.github.io/ac-library/document_en/dsu.html))

* `dsu(n)` => `AtCoder::DSU.new(n)`

  ```cr
  dsu = AtCoder::DSU.new(10)
  dsu.merge(0, 2)
  dsu.merge(4, 2)
  dsu.same?(0, 4) #=> true
  dsu.size(4) #=> 3
  ```

  * `.merge(a, b)` => `#merge(a, b)`
  * `.same(a, b)` => `#same?(a, b)`
  * `.leader(a)` => `#leader(a)`
  * `.size()` => `#size`
  * `.groups()` => `#groups`

    * This method returns set instead of list.

## [`atcoder/max_flow`](https://google.github.io/ac-library.cr/docs/src/max_flow.cr) (Implements [<atcoder/maxflow>](https://atcoder.github.io/ac-library/document_en/maxflow.html))

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

## [`atcoder/scc`](https://google.github.io/ac-library.cr/docs/src/scc.cr) (Impements [<atcoder/scc>](https://atcoder.github.io/ac-library/document_en/scc.html))

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

## [`atcoder/two_sat`](https://google.github.io/ac-library.cr/docs/src/two_sat.cr) (Implements [<atcoder/twosat>](https://atcoder.github.io/ac-library/document_en/twosat.html))

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

## [`atcoder/math`](https://google.github.io/ac-library.cr/docs/src/math.cr) (Implements [<atcoder/math>](https://atcoder.github.io/ac-library/document_en/math.html))

* `pow_mod(x, n, m)` => `AtCoder::Math.pow_mod(x, n, m)`
* `inv_mod(x, m)` => `AtCoder::Math.inv_mod(x, m)`
* `crt(r, m)` => `AtCoder::Math.crt(r, m)`
* `floor_sum` => `AtCoder::Math.floor_sum(n, m, a, b)`

## [`atcoder/convolution`](https://google.github.io/ac-library.cr/docs/src/convolution.cr) (Implements [<atcoder/convolution>](https://atcoder.github.io/ac-library/document_en/convolution.html))

* `convolution(a, b)` => `AtCoder::Convolution.convolution(a, b)`

  ```cr
  a = [AtCoder::ModInt998244353.new(1_i64)] * 3
  AtCoder::Convolution.convolution(a, a) #=> [1, 2, 3, 2, 1]
  ```

* `convolution_ll(a, b)` => `AtCoder::Convolution.convolution_ll(a, b)`

  ```cr
  a = [1_000_000_000_i64]
  AtCoder::Convolution.convolution_ll(a, a) #=> [1000000000000000000]
  ```

## [`atcoder/min_cost_flow`](https://google.github.io/ac-library.cr/docs/src/min_cost_flow.cr) (Implements [<atcoder/mincostflow>](https://atcoder.github.io/ac-library/document_en/mincostflow.html))

* `mcf_graph graph(n)` => `AtCoder::MinCostFlow.new(n)`

  ```cr
  flow = AtCoder::MinCostFlow.new(5)
  flow.add_edge(0, 1, 30, 3)
  flow.add_edge(0, 2, 60, 9)
  flow.add_edge(1, 2, 40, 5)
  flow.add_edge(1, 3, 50, 7)
  flow.add_edge(2, 3, 20, 8)
  flow.add_edge(2, 4, 50, 6)
  flow.add_edge(3, 4, 60, 7)
  flow.flow(0, 4, 70) #=> {70, 1080}
  ```

  * `.add_edge(from, to, cap, cost)` => `#add_edge(from, to, cap, cost)`
  * `.flow(s, t)` => `#flow(s, t)`
  * `.flow(s, t, flow_limit)` => `#flow(s, t, flow_limit)`
  * `.slope(s, t)` => `#slope(s, t)`
  * `.slope(s, t, flow_limit)` => `#slope(s, t, flow_limit)`
  * `.get_edge(i)` => Unimplemented
  * `.edges()` => Unimplemented

## [`atcoder/priority_queue`](https://google.github.io/ac-library.cr/docs/src/priority_queue.cr) (not in ACL)

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

  * `#each`

    Yields each item in the queue in comparator's order.

    ヒープを破壊せず列挙するため、O(NlogN) の前計算を行っています。ただし、`#first` は O(1) で動作するように最適化されています。 it pre-calculates in O(NlogN) to enumerate without destroying the heap. Note, however, that `#first` works for O(1).

    ```cr
    q = AtCoder::PriorityQueue.new(1..n)

    # O(n log(n))
    q.each do |x|
      break
    end

    # O(n log(n) + n) = O(n log(n))
    q.each do |x|
      # something to do in O(1)
    end

    # O(1)
    q.first # => n
    ```


  * `#size`

    Returns size of the queue

  * `#empty?`

    Returns `true` if the queue is empty.

## [`atcoder/prime`](https://google.github.io/ac-library.cr/docs/src/prime.cr) (not in ACL)

* `AtCoder::Prime` (module)

  Implements [Ruby's Prime library](https://ruby-doc.com/stdlib/libdoc/prime/rdoc/prime.html).

  ```cr
  AtCoder::Prime.first(7) # => [2, 3, 5, 7, 11, 13, 17]
  ```
