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
  # Implements atcoder::fenwick_tree.
  #
  # ```
  # tree = AtCoder::FenwickTree(Int64).new(10)
  # tree.add(3, 10)
  # tree.add(5, 20)
  # tree[3..5] # => 30
  # tree[3...5] # => 10
  # ```
  class FenwickTree(T)
    getter size : Int64
    getter bits : Array(T)

    def initialize(@size)
      @bits = Array(T).new(@size, T.zero)
    end

    # Implements atcoder::fenwick_tree.add(index, value)
    def add(index, value)
      index += 1 # convert to 1-indexed
      while index <= @size
        @bits[index - 1] += value
        index += index & -index
      end
    end

    # Exclusive left sum
    def left_sum(index)
      ret = T.zero
      while index >= 1
        ret += @bits[index - 1]
        index -= index & -index
      end
      ret
    end

    # Implements atcoder::fenwick_tree.sum(left, right)
    def sum(left, right)
      left_sum(right) - left_sum(left)
    end

    # :ditto:
    def [](range : Range(Int, Int))
      left = range.begin
      right = range.exclusive? ? range.end : range.end + 1
      sum(left, right)
    end
  end
end