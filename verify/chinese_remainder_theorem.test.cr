# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
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

# verification-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=2659

require "../src/Math.cr"

n, _, d = read_line.split.map(&.to_i64)
ais = read_line.split.map(&.to_i64)
d.times do
  rs = read_line.split.map(&.to_i64)
  tuples = rs.zip(ais).reject {|(r, a)| r == -1}
  unless tuples.empty?
    val, modulo = AtCoder::Math.crt(tuples.map {|(r, a)| r}, tuples.map {|(r, a)| a})
    if {val, modulo} == {0, 0} || n < val
      p -1
      exit
    end
    n = n - (n - val) % modulo
  end
end
p n
