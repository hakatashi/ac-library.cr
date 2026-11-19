# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
#
# Copyright 2023 Google LLC
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

# verification-helper: PROBLEM https://judge.yosupo.jp/problem/bipartitematching

require "../src/max_flow.cr"

l, r, m = read_line.split.map(&.to_i64)
flow = AtCoder::MaxFlow.new(l + r + 2)
l.times { |i| flow.add_edge(0, i + 1, 1) }
r.times { |i| flow.add_edge(l + i + 1, l + r + 1, 1) }
match_edges = Array.new(m) do
  a, b = read_line.split.map(&.to_i64)
  flow.add_edge(a + 1, l + b + 1, 1)
end
p flow.flow(0, l + r + 1)
match_edges.each do |edge_index|
  edge = flow.get_edge(edge_index)
  puts "#{edge.from - 1} #{edge.to - l - 1}" if edge.flow > 0
end
