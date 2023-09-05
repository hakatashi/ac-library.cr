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

require "./math.cr"

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

    def each(&)
      index = 0
      loop do
        yield get_nth_prime(index)
        index += 1
      end
    end

    def prime_division(value : Int)
      raise DivisionByZeroError.new if value == 0

      int = typeof(value)

      factors = [] of Tuple(typeof(value), typeof(value))

      if value < 0
        value = value.abs
        factors << {int.new(-1), int.new(1)}
      end

      until prime?(value) || value == 1
        factor = value
        until prime?(factor)
          factor = find_factor(factor)
        end
        count = 0
        while value % factor == 0
          value //= factor
          count += 1
        end
        factors << {int.new(factor), int.new(count)}
      end

      if value > 1
        factors << {value, int.new(1)}
      end

      factors.sort_by! { |(factor, _)| factor }
    end

    private def find_factor(n : Int)
      # Factor of even numbers cannot be discovered by Pollard's Rho with f(x) = x^x+i
      if n.even?
        typeof(n).new(2)
      else
        pollard_rho(n).not_nil!
      end
    end

    # Get single factor by Pollard's Rho Algorithm
    private def pollard_rho(n : Int)
      typeof(n).new(1).upto(n) do |i|
        x = i
        y = pollard_random_f(x, n, i)

        loop do
          x = pollard_random_f(x, n, i)
          y = pollard_random_f(pollard_random_f(y, n, i), n, i)
          gcd = (x - y).gcd(n)

          if gcd == n
            break
          end

          if gcd != 1
            return gcd
          end
        end
      end
    end

    @[AlwaysInline]
    private def pollard_random_f(n : Int, mod : Int, seed : Int)
      (AtCoder::Math.mul_mod(n, n, mod) + seed) % mod
    end

    private def extract_prime_division_base(prime_divisions_class : Array({T, T}).class) forall T
      T
    end

    def int_from_prime_division(prime_divisions : Array({Int, Int}))
      int_class = extract_prime_division_base(prime_divisions.class)
      prime_divisions.reduce(int_class.new(1)) { |i, (factor, exponent)| i * factor ** exponent }
    end

    def prime?(value : Int)
      # Obvious patterns
      return false if value < 2
      return true if value <= 3
      return false if value.even?
      return true if value < 9

      if value < 0xffff
        return false unless typeof(value).new(30).gcd(value % 30) == 1

        7.step(by: 30, to: value) do |base|
          break if base * base > value

          if {0, 4, 6, 10, 12, 16, 22, 24}.any? { |i| value % (base + i) == 0 }
            return false
          end
        end

        return true
      end

      miller_rabin(value.to_i64)
    end

    private def miller_rabin(value)
      d = value - 1
      s = 0_i64
      until d.odd?
        d >>= 1
        s += 1
      end

      miller_rabin_bases(value).each do |base|
        next if base == value

        x = AtCoder::Math.pow_mod(base.to_i64, d, value)
        next if x == 1 || x == value - 1

        is_composite = s.times.all? do
          x = AtCoder::Math.mul_mod(x, x, value)
          x != value - 1
        end

        return false if is_composite
      end

      true
    end

    # We can reduce time complexity of Miller-Rabin tests by testing against
    # predefined bases which is enough to test against primarity in the given range.
    # https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    # ameba:disable Metrics/CyclomaticComplexity
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
      new_primes = Array(Int64).new(new_primes_size) { |i| @@primes.last + (i + 1) * 2 }
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

    private struct EachDivisor(T)
      include Enumerable(T)

      def initialize(@exponential_factors : Array(Array(T)))
      end

      def each(&)
        Indexable.each_cartesian(@exponential_factors) do |factors|
          yield factors.reduce { |a, b| a * b }
        end
      end
    end

    # Returns an enumerator that iterates through the all positive divisors of
    # the given number. **The order is not guaranteed.**
    # Not in the original Ruby's Prime library.
    #
    # ```
    # AtCoder::Prime.each_divisor(20) do |n|
    #   puts n
    # end # => Puts 1, 2, 4, 5, 10, and 20
    #
    # AtCoder::Prime.each_divisor(10).map { |n| 1.0 / n }.to_a # => [1.0, 0.5, 0.2, 0.1]
    # ```
    def each_divisor(value : Int)
      raise ArgumentError.new unless value > 0

      factors = prime_division(value)

      if value == 1
        exponential_factors = [[value]]
      else
        exponential_factors = factors.map do |(factor, count)|
          cnt = typeof(value).zero + 1
          Array(typeof(value)).new(count + 1) do |i|
            cnt_copy = cnt
            if i < count
              cnt *= factor
            end
            cnt_copy
          end
        end
      end

      EachDivisor(typeof(value)).new(exponential_factors)
    end

    # :ditto:
    def each_divisor(value : T, &block : T ->)
      each_divisor(value).each(&block)
    end
  end
end

struct Int
  def prime?
    AtCoder::Prime.prime?(self)
  end
end
