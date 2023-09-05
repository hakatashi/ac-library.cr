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
  # Implements [atcoder::static_modint](https://atcoder.github.io/ac-library/master/document_en/modint.html).
  #
  # ```
  # AtCoder.static_modint(ModInt101, 101_i64)
  # alias Mint = AtCoder::ModInt101
  # Mint.new(80_i64) + Mint.new(90_i64) # => 89
  # ```
  macro static_modint(name, modulo)
    module AtCoder
      # Implements atcoder::modint{{modulo}}.
      #
      # ```
      # alias Mint = AtCoder::{{name}}
      # Mint.new(30_i64) // Mint.new(7_i64)
      # ```
      struct {{name}}
        {% if modulo == 998_244_353_i64 %}
          MOD = 998_244_353_i64
          M = 998_244_353_u32
          R = 3_296_722_945_u32
          MR = 998_244_351_u32
          M2 = 932_051_910_u32
        {% elsif modulo == 1_000_000_007_i64 %}
          MOD = 1_000_000_007_i64
          M = 1_000_000_007_u32
          R = 2_068_349_879_u32
          MR = 2_226_617_417_u32
          M2 = 582_344_008_u32
        {% else %}
          MOD = {{modulo}}
        {% end %}

        def self.zero
          new
        end

        @@factorials = Array(self).new

        def self.factorial(n)
          if @@factorials.empty?
            @@factorials = Array(self).new(100_000_i64)
            @@factorials << self.new(1)
          end
          @@factorials.size.upto(n) do |i|
            @@factorials << @@factorials.last * i
          end
          @@factorials[n]
        end

        def self.permutation(n, k)
          raise ArgumentError.new("k cannot be greater than n") unless n >= k
          factorial(n) // factorial(n - k)
        end

        def self.combination(n, k)
          raise ArgumentError.new("k cannot be greater than n") unless n >= k
          permutation(n, k) // @@factorials[k]
        end

        def self.repeated_combination(n, k)
          combination(n + k - 1, k)
        end

        def -
          self.class.new(0) - self
        end

        def +
          self
        end

        def +(value)
          self + self.class.new(value)
        end

        def -(value)
          self - self.class.new(value)
        end

        def *(value)
          self * self.class.new(value)
        end

        def /(value)
          raise DivisionByZeroError.new if value == 0
          self / self.class.new(value)
        end

        def /(value : self)
          raise DivisionByZeroError.new if value == 0
          self * value.inv
        end

        def //(value)
          self / value
        end

        def <<(value)
          self * self.class.new(2) ** value
        end

        def abs
          value
        end

        def pred
          self - 1
        end

        def succ
          self + 1
        end

        def zero?
          value == 0
        end

        def to_i64
          value
        end

        def ==(other : self)
          value == other.value
        end

        def ==(other)
          value == other
        end

        def sqrt
          z = self.class.new(1_i64)
          until z ** ((MOD - 1) // 2) == MOD - 1
            z += 1
          end
          q = MOD - 1
          m = 0
          while q.even?
            q //= 2
            m += 1
          end
          c = z ** q
          t = self ** q
          r = self ** ((q + 1) // 2)
          m.downto(2) do |i|
            tmp = t ** (2 ** (i - 2))
            if tmp != 1
              r *= c
              t *= c ** 2
            end
            c *= c
          end
          if r * r == self
            r.to_i64 * 2 <= MOD ? r : -r
          else
            nil
          end
        end

        # ac-library compatibility

        def pow(value)
          self ** value
        end

        def val
          self.to_i64
        end

        # ModInt shouldn't be compared

        def <(value)
          raise NotImplementedError.new("<")
        end
        def <=(value)
          raise NotImplementedError.new("<=")
        end
        def >(value)
          raise NotImplementedError.new(">")
        end
        def >=(value)
          raise NotImplementedError.new(">=")
        end

        {% if modulo == 998_244_353_i64 || modulo == 1_000_000_007_i64 %}
          getter mgy : UInt32

          # Initialize using montgomery representation
          def self.raw(mgy : UInt32)
            ret = new
            ret.mgy = mgy
            ret
          end

          def initialize
            @mgy = 0
          end

          def initialize(value : Int)
            @mgy = reduce(((value % M).to_u64 + M) * M2)
          end

          def clone
            ret = self.class.new
            ret.mgy = @mgy
            ret
          end

          def +(value : self)
            ret = self.class.raw(@mgy)
            ret.mgy = (ret.mgy.to_i64 + value.mgy - 2*M).to_u32!
            if ret.mgy.to_i32! < 0
              ret.mgy = (ret.mgy.to_u64 + 2*M).to_u32!
            end
            ret
          end

          def -(value : self)
            ret = self.class.raw(@mgy)
            ret.mgy = (ret.mgy.to_i64 - value.mgy).to_u32!
            if ret.mgy.to_i32! < 0
              ret.mgy = (ret.mgy.to_u64 + 2*M).to_u32!
            end
            ret
          end

          def *(value : self)
            ret = self.class.raw(@mgy)
            ret.mgy = reduce(ret.mgy.to_u64 * value.mgy)
            ret
          end

          def **(value)
            if value == 0
              return self.class.new(1)
            end

            if self.zero?
              self
            end

            b = value > 0 ? self : inv
            e = value.abs
            ret = self.class.new(1)
            while e > 0
              if e.odd?
                ret *= b
              end
              b *= b
              e >>= 1
            end
            ret
          end

          def inv
            g, x = AtCoder::Math.extended_gcd(value.to_i32, M.to_i32)
            self.class.new(x)
          end

          def to_s(io : IO)
            io << value
          end

          def inspect(io : IO)
            to_s(io)
          end

          def mgy=(v : UInt32)
            @mgy = v
          end

          @[AlwaysInline]
          def reduce(b : UInt64) : UInt32
            ((b + (b.to_u32!.to_u64 * MR).to_u32!.to_u64 * M) >> 32).to_u32
          end

          @[AlwaysInline]
          def value
            ret = reduce(@mgy.to_u64)
            ret >= M ? (ret - M).to_i64 : ret.to_i64
          end
        {% else %}
          getter value : Int64

          def initialize(@value : Int64 = 0_i64)
            @value %= MOD
          end

          def initialize(value)
            @value = value.to_i64 % MOD
          end

          def clone
            self.class.new(@value)
          end

          def inv
            g, x = AtCoder::Math.extended_gcd(@value, MOD)
            self.class.new(x)
          end

          def +(value : self)
            self.class.new(@value + value.to_i64)
          end

          def -(value : self)
            self.class.new(@value - value.to_i64)
          end

          def *(value : self)
            self.class.new(@value * value.to_i64)
          end

          def **(value)
            self.class.new(AtCoder::Math.pow_mod(@value, value.to_i64, MOD))
          end

          delegate to_s, to: @value
          delegate inspect, to: @value
        {% end %}
      end
    end

    struct Int
      def +(value : AtCoder::{{name}})
        value + self
      end

      def -(value : AtCoder::{{name}})
        -value + self
      end

      def *(value : AtCoder::{{name}})
        value * self
      end

      def //(value : AtCoder::{{name}})
        value.inv * self
      end

      def /(value : AtCoder::{{name}})
        self // value
      end

      def ==(value : AtCoder::{{name}})
        value == self
      end
    end
  end
end

AtCoder.static_modint(ModInt1000000007, 1_000_000_007_i64)
AtCoder.static_modint(ModInt998244353, 998_244_353_i64)
AtCoder.static_modint(ModInt754974721, 754_974_721_i64)
AtCoder.static_modint(ModInt167772161, 167_772_161_i64)
AtCoder.static_modint(ModInt469762049, 469_762_049_i64)
