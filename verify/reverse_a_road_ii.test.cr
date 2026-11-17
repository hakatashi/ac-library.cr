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

# verification-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=2594

require "../src/max_flow.cr"

while line = gets
  stripped = line.strip
  next if stripped.empty?

  n, m, s, t = stripped.split.map(&.to_i64)
  break if n == 0 && m == 0 && s == 0 && t == 0

  s -= 1
  t -= 1

  mf = AtCoder::MaxFlow.new(n)
  rev_mf = AtCoder::MaxFlow.new(n)
  edges = Array({Int64, Int64}).new(m)

  m.times do
    a, b = read_line.split.map(&.to_i64)
    a -= 1
    b -= 1
    mf.add_edge(a, b, 1_i64)
    rev_mf.add_edge(b, a, 1_i64)
    edges << {a, b}
  end

  flow = mf.flow(s, t)
  rev_mf.flow(t, s)

  from_s = mf.min_cut(s)
  to_t = rev_mf.min_cut(t)

  count = edges.count { |(u, v)| from_s[v] && to_t[u] }
  if count > 0
    puts "#{flow + 1} #{count}"
  else
    puts "#{flow} 0"
  end
end
