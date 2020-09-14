# ac-library.cr

This is not an officially supported Google product.

ac-library.cr is a Crystal port of [ac-library](https://github.com/atcoder/ac-library).

This library aims to provide the almost-equivalent (and additional) functionality with ac-library but in the manner of Crystal.

For the convinience of usage in programming contest, each class in the library does not depend on the other files and can be independently used.

## [<atcoder/modint>](https://atcoder.github.io/ac-library/document_en/modint.html)

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

## [<atcoder/fenwicktree>](https://atcoder.github.io/ac-library/document_en/fenwicktree.html)

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

## [<atcoder/segtree>](https://atcoder.github.io/ac-library/document_en/segtree.html)

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

## [<atcoder/dsu>](https://atcoder.github.io/ac-library/document_en/dsu.html)

* `dsu(n)` => `AtCoder::DSU.new(n)`

  ```cr
  dsu = AtCoder::DSU.new(10)
  dsu.unite(0, 2)
  dsu.unite(4, 2)
  dsu.same(0, 4) #=> true
  dsu.size(4) #=> 3
  ```

  * `.merge(a, b)` => `#merge(a, b)`
  * `.same(a, b)` => `#same(a, b)`
  * `.leader(a)` => `#leader(a)`
  * `.size()` => `#size`
  * `.groups()` => `#groups`

    * This method returns set instead of list.
