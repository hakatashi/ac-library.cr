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
    def extended_gcd(a, b)
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

    def inv_mod(x, m)
      g, n = extended_gcd(x, m)
      if g != 1
        raise ArgumentError.new("#{x} and #{m} are not coprime")
      end
      n % MOD
    end

    def pow_mod(x, n, m)
      b = x > 0 ? x : inv_mod(x, m)
      e = x.abs
      ret = 1_i64
      while e > 0
        if e % 2 == 1
          ret = ret * b % m
        end
        b = b * b % m
        e //= 2
      end
      ret
    end
  end
end

