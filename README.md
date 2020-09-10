# ac-library.cr

Implementation of [ac-library](https://codeforces.com/blog/entry/82400) in Crystal

The aim of this library is to provide the same (and additional) functianality with ac-library, but in the manner of Crystal.

## modint

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

## segtree

* `segtree<S, op, e> seg(v)` => `AtCoder::SegTree<S>.new(v, op?)`

  単位元は暗黙的にnilで定義されるため使用する際に定義する必要はありません。逆に言えばモノイドの (単位元以外の) 元にnilを含めることはできません。

  * `.set(p, x)` => `#[]=(p, x)`
  * `.get(p)` => `#[](p)`
  * `.prod(l, r)` => `#[](l...r)`
  * `.all_prod()` => `#all_prod`
  * `.max_right<f>(l)` => Unimplemented
  * `.max_left<f>(r)` => Unimplemented
