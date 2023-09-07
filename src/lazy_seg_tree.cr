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
  # Implements [atcoder::lazy_segtree](https://atcoder.github.io/ac-library/master/document_en/lazysegtree.html).
  #
  # The identity element will be implicitly defined as nil, so you don't
  # have to manually define it. In the other words, you cannot include
  # nil into an element of the monoid.
  #
  # Similarly, the identity map of F will be implicitly defined as nil,
  # so you don't have to manually define it. In the other words, you
  # cannot include nil into an element of the set F.
  #
  # ```
  # op = ->(a : Int32, b : Int32) { [a, b].min }
  # mapping = ->(f : Int32, x : Int32) { f }
  # composition = ->(a : Int32, b : Int32) { a }
  # tree = AtCoder::LazySegTree(Int32, Int32).new((0...100).to_a, op, mapping, composition)
  # tree[10...50] # => 10
  # tree[20...60] = 0
  # tree[50...80] # => 0
  # ```
  class LazySegTree(S, F)
    @n : Int32
    @height : Int32
    @n_leaves : Int32

    def initialize(values : Array(S), @operator : S, S -> S, @application : F, S -> S, @composition : F, F -> F)
      @n = values.size

      @height = log2_ceil(@n)
      @n_leaves = 1 << @height

      @segments = Array(S | Nil).new(2 * @n_leaves, nil)
      @applicators = Array(F | Nil).new(@n_leaves, nil)

      # initialize segments
      values.each_with_index { |x, i| @segments[@n_leaves + i] = x.as(S | Nil) }
      (@n_leaves - 1).downto(1) { |i| refresh(i) }
    end

    # Implements atcoder::lazy_segtree.set(index, applicator).
    def set(index : Int, value : S)
      index += @n_leaves
      @height.downto(1) { |j| propagate(ancestor(index, j)) }
      @segments[index] = value.as(S | Nil)
      (1..@height).each { |j| refresh(ancestor(index, j)) }
    end

    # Implements atcoder::lazy_segtree.apply(index, applicator).
    def []=(index : Int, applicator : F)
      index += @n_leaves
      @height.downto(1) { |j| propagate(ancestor(index, j)) }
      @segments[index] = apply(applicator, @segments[index])
      (1..@height).each { |j| refresh(ancestor(index, j)) }
      applicator
    end

    # Implements atcoder::lazy_segtree.apply(left, right, applicator).
    # ameba:disable Metrics/CyclomaticComplexity
    def []=(range : Range, applicator : F)
      l = (range.begin || 0) + @n_leaves
      r = (range.exclusive? ? (range.end || @n_leaves) : (range.end || @n_leaves - 1) + 1) + @n_leaves

      @height.downto(1) do |i|
        propagate(ancestor(l, i)) if right_side_child?(l, i)
        propagate(ancestor(r - 1, i)) if right_side_child?(r, i)
      end

      l2, r2 = l, r
      while l2 < r2
        if l2.odd?
          all_apply(l2, applicator)
          l2 += 1
        end
        if r2.odd?
          r2 -= 1
          all_apply(r2, applicator)
        end
        l2 >>= 1
        r2 >>= 1
      end

      (1..@height).each do |i|
        refresh(ancestor(l, i)) if right_side_child?(l, i)
        refresh(ancestor(r - 1, i)) if right_side_child?(r, i)
      end

      applicator
    end

    # Implements atcoder::lazy_segtree.get(index).
    def [](index : Int)
      index += @n_leaves
      @height.downto(1) { |j| propagate(ancestor(index, j)) }
      @segments[index].not_nil!
    end

    # Implements atcoder::lazy_segtree.prod(left, right).
    def [](range : Range)
      l = (range.begin || 0) + @n_leaves
      r = (range.exclusive? ? (range.end || @n_leaves) : (range.end || @n_leaves - 1) + 1) + @n_leaves

      @height.downto(1) do |i|
        propagate(ancestor(l, i)) if right_side_child?(l, i)
        propagate(ancestor(r - 1, i)) if right_side_child?(r, i)
      end

      sml, smr = nil.as(S | Nil), nil.as(S | Nil)
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

    # Implements atcoder::lazy_segtree.all_prod().
    def all_prod
      self[0...@n]
    end

    # Implements atcoder::lazy_segtree.max_right(left, g).
    def max_right(left, e : S | Nil = nil, & : S -> Bool)
      unless 0 <= left && left <= @n
        raise IndexError.new("{left: #{left}} must greater than or equal to 0 and less than or equal to {n: #{@n}}")
      end

      unless e.nil?
        return nil unless yield e
      end

      return @n if left == @n

      left += @n_leaves
      @height.downto(1) { |i| propagate(ancestor(left, i)) }

      sm = e
      loop do
        while left.even?
          left >>= 1
        end

        res = operate(sm, @segments[left])
        unless res.nil? || yield res
          while left < @n_leaves
            propagate(left)
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

      @n
    end

    # Implements atcoder::lazy_segtree.min_left(right, g).
    def min_left(right, e : S | Nil = nil, & : S -> Bool)
      unless 0 <= right && right <= @n
        raise IndexError.new("{right: #{right}} must greater than or equal to 0 and less than or equal to {n: #{@n}}")
      end

      unless e.nil?
        return nil unless yield e
      end

      return 0 if right == 0

      right += @n_leaves
      @height.downto(1) { |i| propagate(ancestor(right - 1, i)) }
      sm = e
      loop do
        right -= 1
        while right > 1 && right.odd?
          right >>= 1
        end

        res = operate(@segments[right], sm)
        unless res.nil? || yield res
          while right < @n_leaves
            propagate(right)
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
    private def operate(a : S | Nil, b : S | Nil)
      if a.nil?
        b
      elsif b.nil?
        a
      else
        @operator.call(a, b)
      end
    end

    @[AlwaysInline]
    private def apply(f : F | Nil, x : S | Nil)
      if f.nil?
        x
      elsif x.nil?
        nil
      else
        @application.call(f, x)
      end
    end

    @[AlwaysInline]
    private def compose(a : F | Nil, b : F | Nil)
      if a.nil?
        b
      elsif b.nil?
        a
      else
        @composition.call(a, b)
      end
    end

    @[AlwaysInline]
    private def refresh(node : Int)
      child1 = 2*node
      child2 = 2*node + 1
      @segments[node] = operate(@segments[child1], @segments[child2])
    end

    @[AlwaysInline]
    private def all_apply(node, applicator : F | Nil)
      @segments[node] = apply(applicator, @segments[node])
      unless leaf?(node)
        @applicators[node] = compose(applicator, @applicators[node])
      end
    end

    @[AlwaysInline]
    private def propagate(node : Int)
      child1 = 2*node
      child2 = 2*node + 1
      all_apply(child1, @applicators[node])
      all_apply(child2, @applicators[node])
      @applicators[node] = nil
    end

    @[AlwaysInline]
    private def right_side_child?(child, n_gens_ago)
      ((child >> n_gens_ago) << n_gens_ago) != child
    end

    @[AlwaysInline]
    private def ancestor(node, n_gens_ago)
      node >> n_gens_ago
    end

    @[AlwaysInline]
    private def leaf?(node)
      node >= @n_leaves
    end

    @[AlwaysInline]
    private def log2_ceil(n : Int32) : Int32
      sizeof(Int32)*8 - (n - 1).leading_zeros_count
    end
  end
end
