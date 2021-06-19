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

# verification-helper: PROBLEM https://judge.yosupo.jp/problem/shortest_path

require "../src/Graph.cr"

n, m, s, t = read_line.split.map(&.to_i64)
graph = AtCoder::DirectedGraph(Nil, Int64).new(n)
m.times do
  a, b, c = read_line.split.map(&.to_i64)
  graph.add_edge(a, b, c)
end
nodes = graph.dijkstra(s)

ans = nodes[t][:dist]
if ans.nil?
  p -1
else
  path = [t]
  until path.last == s
    path << nodes[path.last][:prev].not_nil!
  end
  puts "#{ans} #{path.size - 1}"
  path.reverse!.each_cons_pair do |a, b|
    puts "#{a} #{b}"
  end
end
