# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2022 Google LLC
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

# verification-helper: PROBLEM https://judge.yosupo.jp/problem/point_add_range_sum

require "../src/FenwickTree.cr"

include AtCoder

n, q = read_line.split.map(&.to_i64)
ais = read_line.split.map(&.to_i64)
tree = FenwickTree(Int64).new(n)
ais.each_with_index do |a, i|
  tree.add(i, a)
end

q.times do
  args = read_line.split.map(&.to_i64)
  if args[0] == 0
    _, p, x = args
    tree.add(p, x)
  else
    _, l, r = args
    p tree[l...r]
  end
end
