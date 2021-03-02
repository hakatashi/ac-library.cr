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

    def each
      index = 0
      loop do
        yield get_nth_prime(index)
        index += 1
      end
    end

    # TODO: Rewrite with Pollard Rho algorithm
    def prime_division(value)
      raise DivisionByZeroError.new if value == 0

      factors = [] of Tuple(Int64, Int64)

      if value < 0
        value = value.abs
        factors << {-1_i64, 1_i64}
      end

      each do |prime|
        count = 0_i64
        while value % prime == 0
          value //= prime
          count += 1
        end
        if count != 0
          factors << {prime, count}
        end
        break if value <= prime * prime
      end

      if value > 1
        factors << {value, 1_i64}
      end

      factors
    end

    def prime?(value : Int64)
      # Obvious patterns
      return false if value < 2
      return true if value <= 3
      return true if value == 5
      return false if value.even?

      if value < 0xffff
        return false unless 30_i64.gcd(value % 30) == 1

        7.step(by: 30, to: value) do |base|
          break if base * base > value

          if {0, 4, 6, 10, 12, 16, 22, 24}.any? {|i| value % (base + i) == 0}
            return false
          end
        end

        return true
      end

      d = value - 1
      s = 0_i64
      until d.odd?
        d >>= 1
        s += 1
      end

      miller_rabin_bases(value).each do |base|
        next if base == value

        x = pow_mod(base.to_i64, d, value)
        next if x == 1 || x == value - 1

        is_composite = s.times.all? do
          x = mul_mod(x, x, value)
          x != value - 1
        end

        return false if is_composite
      end

      true
    end

    # Simplified AtCoder::Math.pow_mod with support of Int64
    private def pow_mod(base, exponent, modulo)
      if base == 0
        return base
      end
      b = base
      e = exponent.abs
      ret = 1_i64
      while e > 0
        if e % 2 == 1
          ret = mul_mod(ret, b, modulo)
        end
        b = mul_mod(b, b, modulo)
        e //= 2
      end
      ret
    end

    # Caluculates a * b % mod without overflow detection
    private def mul_mod(a, b, mod)
      if (!a.is_a?(Int64) && !b.is_a?(Int64)) || mod < Int32::MAX
        return a * b % mod
      end

      # 31-bit width
      a_high = (a >> 32).to_u64
      # 32-bit width
      a_low = (a & 0xFFFFFFFF).to_u64
      # 31-bit width
      b_high = (b >> 32).to_u64
      # 32-bit width
      b_low = (b & 0xFFFFFFFF).to_u64

      # 31-bit + 32-bit + 1-bit = 64-bit
      c = a_high * b_low + b_high * a_low
      c_high = c >> 32
      c_low = c & 0xFFFFFFFF

      # 31-bit + 31-bit
      res_high = a_high * b_high + c_high
      # 32-bit + 32-bit
      res_low = a_low * b_low
      res_low_high = res_low >> 32
      res_low_low = res_low & 0xFFFFFFFF
      
      # Overflow
      if res_low_high + c_low >= 0x100000000
        res_high += 1
      end

      res_low = (((res_low_high + c_low) & 0xFFFFFFFF) << 32) | res_low_low

      (((res_high.to_i128 << 64) | res_low) % mod).to_i64
    end

    # We can reduce time complexity of Miller-Rabin tests by testing against
    # predefined bases which is enough to test against primarity in the given range.
    # https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    private def miller_rabin_bases(value)
      case
      when value < 1_373_653_i64
        [2, 3]
      when value < 9_080_191_i64
        [31, 73]
      when value < 25_326_001_i64
        [2, 3, 5]
      when value < 3_215_031_751_i64
        [2, 3, 5, 7]
      when value < 4_759_123_141_i64
        [2, 7, 61]
      when value < 1_122_004_669_633_i64
        [2, 13, 23, 1662803]
      when value < 2_152_302_898_747_i64
        [2, 3, 5, 7, 11]
      when value < 3_474_749_660_383_i64
        [2, 3, 5, 7, 11, 13]
      when value < 341_550_071_728_321_i64
        [2, 3, 5, 7, 11, 13, 17]
      when value < 3_825_123_056_546_413_051_i64
        [2, 3, 5, 7, 11, 13, 17, 19, 23]
      else
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
      end
    end

    private def get_nth_prime(n)
      while @@primes.size <= n
        generate_primes
      end

      @@primes[n]
    end

    # Doubles the size of the cached prime array and performs the
    # Sieve of Eratosthenes on it.
    private def generate_primes
      new_primes_size = @@primes.size < 1_000_000 ? @@primes.size : 1_000_000
      new_primes = Array(Int64).new(new_primes_size) {|i| @@primes.last + (i + 1) * 2}
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
