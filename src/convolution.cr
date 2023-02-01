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

module AtCoder
  # Implements [atcoder::convolution](https://atcoder.github.io/ac-library/master/document_en/convolution.html).
  #
  # ```
  # a = [AtCoder::ModInt998244353.new(1_i64)] * 3
  # AtCoder::Convolution.convolution(a, a) # => [1, 2, 3, 2, 1]
  # ```
  module Convolution
    private def self.bit_reverse(n : Int, bit_length : Int)
      ret = n.class.zero
      bit_length.times do |i|
        ret |= ((n >> i) & 1) << (bit_length - i - 1)
      end
      ret
    end

    # In-place execution of FFT operation.
    # `T` must implement ModInt operations.
    # Length of `a` must be power of 2.
    private def self.fft(a : Array(T), g : T) forall T
      size = a.size
      bit_length = size.trailing_zeros_count

      size.times do |i|
        j = bit_reverse(i, bit_length)
        if i < j
          a[i], a[j] = a[j], a[i]
        end
      end

      bit_length.times do |bit|
        block_size = 1_i64 << bit

        # Butterfly operation
        block_size.times do |i|
          w = (g ** (size // block_size // 2)) ** i
          (size // (block_size * 2)).times do |j|
            index1 = j * 2 * block_size + i
            index2 = (j * 2 + 1) * block_size + i
            a[index1], a[index2] = {
              a[index1] + a[index2] * w,
              a[index1] - a[index2] * w,
            }
          end
        end
      end
    end

    private def self.ifft(a, g)
      fft(a, g.inv)
      a.size.times do |i|
        a[i] //= a.size
      end
    end

    # Implements atcoder::convolution.convolution.
    # TODO: Support for int
    def self.convolution(a : Array(T), b : Array(T)) forall T
      return [] of T if a.empty? || b.empty?

      modulo = T::MOD
      n = modulo - 1
      result_size = a.size + b.size - 1

      c = 1_i64 << n.trailing_zeros_count

      if result_size > c
        raise ArgumentError.new("With modulo #{modulo}, total array length must be less than or equal to #{c}")
      end

      fft_size = 1_i64
      until fft_size >= result_size
        fft_size <<= 1
      end

      input_a = Array(T).new(fft_size) { |i| i < a.size ? a[i] : T.zero }
      input_b = Array(T).new(fft_size) { |i| i < b.size ? b[i] : T.zero }

      primitive_root = AtCoder::Math.get_primitive_root(modulo)
      g = T.new(primitive_root) ** (n // fft_size)

      fft(input_a, g)
      fft(input_b, g)

      fft_size.times do |i|
        input_a[i] *= input_b[i]
      end

      ifft(input_a, g)

      input_a[0...result_size]
    end

    # Implements atcoder::convolution.convolution_ll.
    def self.convolution_ll(a : Array(Int64), b : Array(Int64))
      return [] of Int64 if a.empty? || b.empty?

      a1 = a.map { |n| AtCoder::ModInt754974721.new(n) }
      a2 = a.map { |n| AtCoder::ModInt167772161.new(n) }
      a3 = a.map { |n| AtCoder::ModInt469762049.new(n) }

      b1 = b.map { |n| AtCoder::ModInt754974721.new(n) }
      b2 = b.map { |n| AtCoder::ModInt167772161.new(n) }
      b3 = b.map { |n| AtCoder::ModInt469762049.new(n) }

      c1 = convolution(a1, b1)
      c2 = convolution(a2, b2)
      c3 = convolution(a3, b3)

      m1 = 754_974_721_i64
      m2 = 167_772_161_i64
      m3 = 469_762_049_i64

      c1.zip(c2, c3).map do |n1, n2, n3|
        p = AtCoder::Math.inv_mod(m1, m2)
        tmp = (n2.val - n1.val) * p % m2
        answer = n1.val + m1 * tmp

        p = AtCoder::Math.inv_mod(m1 * m2, m3)
        tmp = (((n3.val - answer) % m3) * p) % m3
        answer + m1 * m2 * tmp
      end
    end
  end
end
