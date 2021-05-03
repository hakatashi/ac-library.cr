# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# verify-helper: PROBLEM https://judge.yosupo.jp/problem/range_affine_range_sum

require "./LazySegTree.cr"
require "./ModInt.cr"

_, q = read_line.split.map(&.to_i64)
ais = read_line.split.map(&.to_i64)

alias Mint = AtCoder::ModInt998244353
alias Segment = NamedTuple(sum: Mint, size: Int64)
alias Affine = NamedTuple(b: Mint, c: Mint)

op = ->(a : Segment, b : Segment) { {sum: a[:sum] + b[:sum], size: a[:size] + b[:size]} }
mapping = ->(f : Affine, x : Segment) { {sum: f[:b] * x[:sum] + f[:c] * x[:size], size: x[:size]} }
composition = ->(a : Affine, b : Affine) { {b: a[:b] * b[:b], c: b[:c] * a[:b] + a[:c]} }
segments = ais.map {|a| {sum: Mint.new(a), size: 1_i64} }
tree = AtCoder::LazySegTree(Segment, Affine).new(segments, op, mapping, composition)

q.times do
  args = read_line.split.map(&.to_i64)
  if args[0] == 0
    _, l, r, b, c = args
    tree[l...r] = {b: Mint.new(b), c: Mint.new(c)}
  else
    _, l, r = args
    p tree[l...r][:sum]
  end
end
