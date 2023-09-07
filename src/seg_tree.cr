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
  # Implements [atcoder::segtree](https://atcoder.github.io/ac-library/master/document_en/segtree.html).
  #
  # The identity element will be implicitly defined as nil, so you don't
  # have to manually define it. In the other words, you cannot include
  # nil into an element of the monoid.
  #
  # ```
  # tree = AtCoder::SegTree.new((0...100).to_a) { |a, b| [a, b].min }
  # tree[10...50] # => 10
  # ```
  class SegTree(T)
    getter values : Array(T)

    @height : Int32
    @n_leaves : Int32

    def initialize(values : Array(T))
      initialize(values) { |a, b| a > b ? a : b }
    end

    def initialize(@values : Array(T), &@operator : T, T -> T)
      @height = log2_ceil(@values.size)
      @n_leaves = 1 << @height

      @segments = Array(T | Nil).new(2 * @n_leaves, nil)

      # initialize segments
      values.each_with_index { |x, i| @segments[@n_leaves + i] = x.as(T | Nil) }
      (@n_leaves - 1).downto(1) { |i| refresh(i) }
    end

    @[AlwaysInline]
    private def operate(a : T | Nil, b : T | Nil)
      if a.nil?
        b
      elsif b.nil?
        a
      else
        @operator.call(a, b)
      end
    end

    # Implements atcoder::segtree.set(index, value)
    def []=(index : Int, value : T)
      @values[index] = value

      index += @n_leaves
      @segments[index] = value.as(T | Nil)
      (1..@height).each { |j| refresh(ancestor(index, j)) }
    end

    # Implements atcoder::segtree.get(index)
    def [](index : Int)
      @values[index]
    end

    # Implements atcoder::segtree.prod(l, r)
    def [](range : Range)
      l = (range.begin || 0) + @n_leaves
      r = (range.exclusive? ? (range.end || @n_leaves) : (range.end || @n_leaves - 1) + 1) + @n_leaves

      sml, smr = nil.as(T | Nil), nil.as(T | Nil)
      while l < r
        if l.odd?
          sml = operate(sml, @segments[l])
          l += 1
        end
        if r.odd?
          r -= 1
          smr = operate(@segments[r], smr)
        end
        l >>= 1
        r >>= 1
      end

      operate(sml, smr).not_nil!
    end

    # compatibility with ac-library

    # Implements atcoder::segtree.set(index, value)
    # alias of `.[]=`
    def set(index : Int, value : T)
      self.[]=(index, value)
    end

    # Implements atcoder::segtree.get(index)
    # alias of `.[]`
    def get(index : Int)
      self.[](index)
    end

    # Implements atcoder::segtree.prod(left, right)
    def prod(left : Int, right : Int)
      self.[](left...right)
    end

    # Implements atcoder::segtree.all_prod(l, r)
    def all_prod
      @segments[1].not_nil!
    end

    # Implements atcoder::lazy_segtree.max_right(left, g).
    def max_right(left, e : T | Nil = nil, & : T -> Bool)
      unless 0 <= left && left <= @values.size
        raise IndexError.new("{left: #{left}} must greater than or equal to 0 and less than or equal to {n: #{@values.size}}")
      end

      unless e.nil?
        return nil unless yield e
      end

      return @values.size if left == @values.size

      left += @n_leaves
      sm = e
      loop do
        while left.even?
          left >>= 1
        end

        res = operate(sm, @segments[left])
        unless res.nil? || yield res
          while left < @n_leaves
            left = 2*left
            res = operate(sm, @segments[left])
            if res.nil? || yield res
              sm = res
              left += 1
            end
          end
          return left - @n_leaves
        end

        sm = operate(sm, @segments[left])
        left += 1

        ffs = left & -left
        break if ffs == left
      end

      @values.size
    end

    # Implements atcoder::lazy_segtree.min_left(right, g).
    def min_left(right, e : T | Nil = nil, & : T -> Bool)
      unless 0 <= right && right <= @values.size
        raise IndexError.new("{right: #{right}} must greater than or equal to 0 and less than or equal to {n: #{@values.size}}")
      end

      unless e.nil?
        return nil unless yield e
      end

      return 0 if right == 0

      right += @n_leaves
      sm = e
      loop do
        right -= 1
        while right > 1 && right.odd?
          right >>= 1
        end

        res = operate(@segments[right], sm)
        unless res.nil? || yield res
          while right < @n_leaves
            right = 2*right + 1
            res = operate(@segments[right], sm)
            if res.nil? || yield res
              sm = res
              right -= 1
            end
          end
          return right + 1 - @n_leaves
        end

        sm = operate(@segments[right], sm)

        ffs = right & -right
        break if ffs == right
      end

      0
    end

    @[AlwaysInline]
    private def refresh(node : Int)
      child1 = 2*node
      child2 = 2*node + 1
      @segments[node] = operate(@segments[child1], @segments[child2])
    end

    @[AlwaysInline]
    private def ancestor(node, n_gens_ago)
      node >> n_gens_ago
    end

    @[AlwaysInline]
    private def log2_ceil(n : Int32) : Int32
      sizeof(Int32)*8 - (n - 1).leading_zeros_count
    end

    @[AlwaysInline]
    private def log2_ceil(n : Int32) : Int32
      sizeof(Int32)*8 - (n - 1).leading_zeros_count
    end
  end
end
