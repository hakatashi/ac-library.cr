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

# verification-helper: PROBLEM https://judge.yosupo.jp/problem/factorize

require "../src/prime.cr"

q = read_line.to_i64
q.times do
  a = read_line.to_i64
  factors = AtCoder::Prime.prime_division(a)
  ans = factors.reduce([] of Int64) {|acc, (prime, count)| acc + [prime] * count}
  puts "#{ans.size} #{ans.join(' ')}"
end
