# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
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
  class FenwickTree(T)
    getter size : Int64
    getter bits : Array(T)

    def initialize(@size)
      @bits = Array(T).new(@size, T.zero)
    end

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

    def sum(left, right)
      left_sum(right) - left_sum(left)
    end

    def [](range : Range(Int, Int))
      left = range.begin
      right = range.exclusive? ? range.end : range.end + 1
      sum(left, right)
    end
  end
end