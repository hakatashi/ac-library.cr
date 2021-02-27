# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
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

module AtCoder
  module Math
    def self.extended_gcd(a, b)
      last_remainder, remainder = a.abs, b.abs
      x, last_x, y, last_y = 0_i64, 1_i64, 1_i64, 0_i64
      while remainder != 0
        new_last_remainder = remainder
        quotient, remainder = last_remainder.divmod(remainder)
        last_remainder = new_last_remainder
        x, last_x = last_x - quotient * x, x
        y, last_y = last_y - quotient * y, y
      end

      return last_remainder, last_x * (a < 0 ? -1 : 1)
    end

    def self.inv_mod(value, modulo)
      gcd, inv = extended_gcd(value, modulo)
      if gcd != 1
        raise ArgumentError.new("#{value} and #{modulo} are not coprime")
      end
      inv % modulo
    end

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
          ret = ret * b % modulo
        end
        b = b * b % modulo
        e //= 2
      end
      ret
    end

    def self.crt(remainders, modulos)
      raise ArgumentError.new unless remainders.size == modulos.size

      if remainders.size == 1
        return 0_i64, 1_i64
      end

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
  end
end
