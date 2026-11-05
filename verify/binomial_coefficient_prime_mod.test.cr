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

# verification-helper: PROBLEM https://judge.yosupo.jp/problem/binomial_coefficient_prime_mod

require "../src/mod_int.cr"

alias Mint = AtCoder::DynamicModInt

t, m = read_line.split.map(&.to_i64)
Mint.set_mod(m)

queries = Array.new(t) do
  n, k = read_line.split.map(&.to_i64)
  {n, k}
end

max_n = queries.max_of { |(n, _)| n }
factorials = Array.new(max_n + 1, Mint.new(1))
1.upto(max_n) { |i| factorials[i] = factorials[i - 1] * i }
inv_factorials = Array.new(max_n + 1, Mint.new(1))
inv_factorials[max_n] = factorials[max_n].inv
max_n.downto(1) { |i| inv_factorials[i - 1] = inv_factorials[i] * i }

output = String.build do |io|
  queries.each do |(n, k)|
    if k > n
      io << 0 << '\n'
    else
      io << factorials[n] * inv_factorials[k] * inv_factorials[n - k] << '\n'
    end
  end
end
print output
