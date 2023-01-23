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

# verification-helper: PROBLEM https://judge.yosupo.jp/problem/enumerate_primes

require "../src/prime.cr"

n, a, b = read_line.split.map(&.to_i64)
ans = Array(Int64).new(1_000_000_i64)
pi = 0_i64
AtCoder::Prime.each_with_index do |prime, i|
  break if prime > n
  pi += 1
  if i >= b && (i - b) % a == 0
    ans << prime
  end
end

puts "#{pi} #{ans.size}"
puts ans.join(' ')
