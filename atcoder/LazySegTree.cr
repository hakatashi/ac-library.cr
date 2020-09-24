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
  class LazySegTree(S, F)
    getter values : Array(S | Nil)

    def initialize(values : Array(S), @operator : S, S -> S, @application : F, S -> S, @composition : F, F -> F)
      @values = values.map {|v| v.as(S | Nil)}
      segment_size = 2 ** Math.log2(@values.size).ceil.to_i - 1
      @segments = Array(S | Nil).new(segment_size, nil)
      @applicators = Array(F | Nil).new(segment_size, nil)

      # initialize segments
      (@segments.size - 1).downto(0) do |i|
        child1 = nil.as(S | Nil)
        child2 = nil.as(S | Nil)
        if i * 2 + 1 < @segments.size
          child1 = @segments[i * 2 + 1]
          child2 = @segments[i * 2 + 2]
        else
          if i * 2 + 1 - @segments.size < @values.size
            child1 = @values[i * 2 + 1 - @segments.size]
          end
          if i * 2 + 2 - @segments.size < @values.size
            child2 = @values[i * 2 + 2 - @segments.size]
          end
        end
        @segments[i] = operate(child1, child2)
      end
    end

    def []=(index : Int, applicator : F)
      apply_range(index, index + 1, applicator, 0, 0...(@segments.size + 1))
    end

    def []=(range : Range(Int, Int), applicator : F)
      l = range.begin
      r = range.exclusive? ? range.end : range.end + 1
      apply_range(l, r, applicator, 0, 0...(@segments.size + 1))
    end

    def [](index : Int)
      get_range(index, index + 1, 0, 0...(@segments.size + 1)).not_nil!
    end

    def [](range : Range(Int, Int))
      l = range.begin
      r = range.exclusive? ? range.end : range.end + 1
      get_range(l, r, 0, 0...(@segments.size + 1)).not_nil!
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

    # range must be exclusive
    # assert(segment_index < @segments.size)
    # assert(range.end - range.begin > 1)
    def eval_segment(segment_index : Int, range : Range(Int, Int))
      applicator = @applicators[segment_index]
      return if applicator.nil?

      @segments[segment_index] = apply(applicator, @segments[segment_index])

      if range.end - range.begin > 2
        @applicators[segment_index * 2 + 1] = compose(applicator, @applicators[segment_index * 2 + 1])
        @applicators[segment_index * 2 + 2] = compose(applicator, @applicators[segment_index * 2 + 2])
      else
        @values[segment_index * 2 + 1 - @segments.size] = apply(applicator, @values[segment_index * 2 + 1 - @segments.size])
        @values[segment_index * 2 + 2 - @segments.size] = apply(applicator, @values[segment_index * 2 + 2 - @segments.size])
      end

      @applicators[segment_index] = nil
    end

    # range must be exclusive
    def apply_range(a : Int, b : Int, f : F, segment_index : Int, range : Range(Int, Int))
      if segment_index >= @segments.size + @values.size
        return nil
      end

      if segment_index < @segments.size
        eval_segment(segment_index, range)
      end

      if range.end <= a || b <= range.begin
        if segment_index < @segments.size
          return @segments[segment_index]
        else
          return @values[segment_index - @segments.size]
        end
      end

      if a <= range.begin && range.end <= b
        if segment_index < @segments.size
          @applicators[segment_index] = compose(@applicators[segment_index], f)
          eval_segment(segment_index, range)
          return @segments[segment_index]
        else
          @values[segment_index - @segments.size] = apply(f, @values[segment_index - @segments.size])
          return @values[segment_index - @segments.size]
        end
      end

      range_median = (range.begin + range.end) // 2
      child1 = apply_range(a, b, f, segment_index * 2 + 1, range.begin...range_median)
      child2 = apply_range(a, b, f, segment_index * 2 + 2, range_median...range.end)

      @segments[segment_index] = operate(child1, child2)
      @segments[segment_index]
    end

    # range must be exclusive
    def get_range(a : Int, b : Int, segment_index : Int, range : Range(Int, Int))
      if range.end <= a || b <= range.begin
        return nil
      end

      if segment_index < @segments.size
        eval_segment(segment_index, range)
      end

      if a <= range.begin && range.end <= b
        if segment_index < @segments.size
          return @segments[segment_index]
        else
          return @values[segment_index - @segments.size]
        end
      end

      range_median = (range.begin + range.end) // 2
      child1 = get_range(a, b, segment_index * 2 + 1, range.begin...range_median)
      child2 = get_range(a, b, segment_index * 2 + 2, range_median...range.end)

      operate(child1, child2)
    end

    def all_prod
      self[0...@values.size]
    end
  end
end
