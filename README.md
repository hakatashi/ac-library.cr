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

* `static_modint` => `static_modint`

  ```cr
  static_modint(ModInt101, 101_i64)
  alias Mint = AtCoder::ModInt101
  Mint.new(80_i64) + Mint.new(90_i64) #=> 89
  ```

* `dynamic_modint` => Unimplemented
