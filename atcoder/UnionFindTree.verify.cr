# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
#
# Copyright 2020 Google LLC
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

# verify-helper: PROBLEM https://judge.yosupo.jp/problem/unionfind

require "./UnionFindTree.cr"

n, q = read_line.split.map(&.to_i64)
tree = UnionFindTree.new(n)

q.times do
  t, u, v = read_line.split.map(&.to_i64)
  if t == 0
    tree.unite(u, v)
  else
    if tree.same(u, v)
      p 1
    else
      p 0
    end
  end
end
