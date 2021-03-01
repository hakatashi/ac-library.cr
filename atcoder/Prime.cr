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

module AtCoder
  # Implements [Ruby's Prime library](https://ruby-doc.com/stdlib/libdoc/prime/rdoc/Prime.html).
  #
  # ```
  # AtCoder::Prime.first(7) # => [2, 3, 5, 7, 11, 13, 17]
  # ```
  module Prime
    extend self
    include Enumerable(Int64)

    @@primes = [
      2_i64, 3_i64, 5_i64, 7_i64, 11_i64, 13_i64, 17_i64, 19_i64,
      23_i64, 29_i64, 31_i64, 37_i64, 41_i64, 43_i64, 47_i64,
      53_i64, 59_i64, 61_i64, 67_i64, 71_i64, 73_i64, 79_i64,
      83_i64, 89_i64, 97_i64, 101_i64,
    ]

    @@index = -1

    def each
      loop do
        yield succ
      end
    end

    private def succ
      @@index += 1

      while @@primes.size <= @@index
        generate_primes
      end

      @@primes[@@index]
    end

    # Doubles the size of the cached prime array and performs the
    # Sieve of Eratosthenes on it.
    private def generate_primes
      new_primes_size = @@primes.size < 1_000_000 ? @@primes.size : 1_000_000
      new_primes = Array(Int64).new(new_primes_size) {|i| (@@primes.last + (i + 1) * 2).to_i64}
      new_primes_max = new_primes.last

      @@primes.each do |prime|
        next if prime == 2
        break if prime * prime > new_primes_max

        # Here I use the technique of the Sieve of Sundaram. We can
        # only test against the odd multiple of the given prime.
        # min_composite is the minimum number that is greater than
        # the last confirmed prime, and is an odd multiple of
        # the given prime.
        min_multiple = ((@@primes.last // prime + 1) // 2 * 2 + 1) * prime
        min_multiple.step(by: prime * 2, to: new_primes_max) do |multiple|
          index = new_primes_size - (new_primes_max - multiple) // 2 - 1
          new_primes[index] = 0_i64
        end
      end

      @@primes.concat(new_primes.reject(0_i64))
    end
  end
end
