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

# verify-helper: PROBLEM https://judge.yosupo.jp/problem/bipartitematching

require "../atcoder/MaxFlow.cr"

l, r, m = read_line.split.map(&.to_i64)
flow = AtCoder::MaxFlow.new(l + r + 2)
l.times {|i| flow.add_edge(0, i + 1, 1) }
r.times {|i| flow.add_edge(l + i + 1, l + r + 1, 1) }
m.times do
  a, b = read_line.split.map(&.to_i64)
  flow.add_edge(a + 1, l + b + 1, 1)
end
p flow.flow(0, l + r + 1)
l.times do |i|
  flow.adjacencies[i + 1].each do |edge|
    if edge.to != 0 && edge.capacity == 0
      puts "#{i} #{edge.to - l - 1}"
      break
    end
  end
end
