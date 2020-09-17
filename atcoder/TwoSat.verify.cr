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

# verify-helper: PROBLEM https://judge.yosupo.jp/problem/two_sat

require "./TwoSat.cr"

_, _, nt, mt = read_line.split
n = nt.to_i64
m = mt.to_i64

twosat = AtCoder::TwoSat.new(n)
m.times do
  a, b, _ = read_line.split.map(&.to_i64)
  twosat.add_clause(a.abs - 1, a > 0, b.abs - 1, b > 0)
end

if twosat.satisfiable?
  solution = twosat.answer
  variables = solution.map_with_index {|a, i| a ? i + 1 : -(i + 1)} .join(" ")
  puts "s SATISFIABLE"
  puts "v #{variables} 0"
else
  puts "s UNSATISFIABLE"
end
