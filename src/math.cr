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

require "./prime.cr"

module AtCoder
  # Implements [ACL's Math library](https://atcoder.github.io/ac-library/master/document_en/math.html)
  module Math
    def self.extended_gcd(a, b)
      zero = a.class.zero
      one = zero + 1

      last_remainder, remainder = a.abs, b.abs
      x, last_x, y, last_y = zero, one, one, zero
      while remainder != 0
        quotient, new_remainder = last_remainder.divmod(remainder)
        last_remainder, remainder = remainder, new_remainder
        x, last_x = last_x - quotient * x, x
        y, last_y = last_y - quotient * y, y
      end

      return last_remainder, last_x * (a < 0 ? -1 : 1)
    end

    # Implements atcoder::inv_mod(value, modulo).
    def self.inv_mod(value, modulo)
      gcd, inv = extended_gcd(value, modulo)
      if gcd != 1
        raise ArgumentError.new("#{value} and #{modulo} are not coprime")
      end
      inv % modulo
    end

    # Simplified AtCoder::Math.pow_mod with support of Int64
    def self.pow_mod(base, exponent, modulo)
      if exponent == 0
        return base.class.zero + 1
      end
      if base == 0
        return base
      end
      b = exponent > 0 ? base : inv_mod(base, modulo)
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
    @[AlwaysInline]
    def self.mul_mod(a : Int64, b : Int64, mod : Int64)
      if mod < Int32::MAX
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

    @[AlwaysInline]
    def self.mul_mod(a, b, mod)
      typeof(mod).new(a.to_i64 * b % mod)
    end

    # Implements atcoder::crt(remainders, modulos).
    def self.crt(remainders, modulos)
      raise ArgumentError.new unless remainders.size == modulos.size

      total_modulo = 1_i64
      answer = 0_i64

      remainders.zip(modulos).each do |(remainder, modulo)|
        gcd, p = extended_gcd(total_modulo, modulo)
        if (remainder - answer) % gcd != 0
          return 0_i64, 0_i64
        end
        tmp = (remainder - answer) // gcd * p % (modulo // gcd)
        answer += total_modulo * tmp
        total_modulo *= modulo // gcd
      end

      return answer % total_modulo, total_modulo
    end

    # Implements atcoder::floor_sum(n, m, a, b).
    def self.floor_sum(n, m, a, b)
      n, m, a, b = n.to_i64, m.to_i64, a.to_i64, b.to_i64
      res = 0_i64

      if a < 0
        a2 = a % m
        res -= n * (n - 1) // 2 * ((a2 - a) // m)
        a = a2
      end

      if b < 0
        b2 = b % m
        res -= n * ((b2 - b) // m)
        b = b2
      end

      res + floor_sum_unsigned(n, m, a, b)
    end

    private def self.floor_sum_unsigned(n, m, a, b)
      res = 0_i64

      loop do
        if a >= m
          res += n * (n - 1) // 2 * (a // m)
          a = a % m
        end

        if b >= m
          res += n * (b // m)
          b = b % m
        end

        y_max = a * n + b
        break if y_max < m

        n = y_max // m
        b = y_max % m
        m, a = a, m
      end

      res
    end

    # Returns `a * b > target`, without concern of overflows.
    def self.product_greater_than(a : Int, b : Int, target : Int)
      target // b < a
    end

    def self.get_primitive_root(p : Int)
      return 1_i64 if p == 2
      n = p - 1
      factors = AtCoder::Prime.prime_division(n)
      (2_i64..p.to_i64).each do |g|
        ok = true
        factors.each do |(factor, _)|
          if pow_mod(g, n // factor, p) == 1
            ok = false
            break
          end
        end
        if ok
          return g
        end
      end
      raise ArgumentError.new
    end
  end
end
