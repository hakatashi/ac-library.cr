# ac-library.cr by Koki Takahashi
# https://github.com/hakatashi/ac-library.cr
# Licensed under MIT License https://hakatashi.mit-license.org

module AtCoder
  class SegTree(T)
    property values : Array(T)

    def initialize(values : Array(T))
      initialize(values) {|a, b| a > b ? a : b}
    end

    def initialize(values : Array(T), &block : T, T -> T)
      @compare_proc = block
      @values = values
      @segments = Array(T | Nil).new(2 ** Math.log2(values.size).ceil.to_i, nil)

      # initialize segments
      (@segments.size - 2).downto(0) do |i|
        child1 = nil.as(T | Nil)
        child2 = nil.as(T | Nil)
        if i * 2 + 2 < @segments.size
          child1 = @segments[i * 2 + 1]
          child2 = @segments[i * 2 + 2]
        else
          if i * 2 + 2 - @segments.size < @values.size
            child1 = @values[i * 2 + 2 - @segments.size]
          end
          if i * 2 + 3 - @segments.size < @values.size
            child2 = @values[i * 2 + 3 - @segments.size]
          end
        end
        if !child1.nil? && !child2.nil?
          @segments[i] = @compare_proc.call(child1, child2)
        elsif !child1.nil? && child2.nil?
          @segments[i] = child1
        end
      end
    end

    def []=(index : Int, value : T)
      @values[index] = value

      child = value
      parent_index = (index + @segments.size - 2) // 2
      while parent_index >= 0
        i = parent_index
        child1 = nil.as(T | Nil)
        child2 = nil.as(T | Nil)
        if i * 2 + 2 < @segments.size
          child1 = @segments[i * 2 + 1]
          child2 = @segments[i * 2 + 2]
        else
          if i * 2 + 2 - @segments.size < @values.size
            child1 = @values[i * 2 + 2 - @segments.size]
          end
          if i * 2 + 3 - @segments.size < @values.size
            child2 = @values[i * 2 + 3 - @segments.size]
          end
        end
        if !child1.nil? && !child2.nil?
          @segments[i] = @compare_proc.call(child1, child2)
        elsif !child1.nil? && child2.nil?
          @segments[i] = child1
        end
        parent_index = (parent_index - 1) // 2
      end
    end

    def [](index : Int)
      @values[index]
    end

    def [](range : Range(Int, Int))
      a = range.begin
      b = range.exclusive? ? range.end : range.end + 1
      get_value(a, b, 0, 0...@segments.size).not_nil!
    end

    def get_value(a : Int, b : Int, segment_index : Int, range : Range(Int, Int))
      if range.end <= a || b <= range.begin
        return nil
      end
      if a <= range.begin && range.end <= b
        if segment_index + 1 < @segments.size
          return @segments[segment_index]
        else
          return @values[segment_index + 1 - @segments.size]
        end
      end
      range_median = (range.begin + range.end) // 2
      child1 = get_value(a, b, 2 * segment_index + 1, range.begin...range_median)
      child2 = get_value(a, b, 2 * segment_index + 2, range_median...range.end)
      if !child1.nil? && !child2.nil?
        @compare_proc.call(child1, child2)
      elsif !child1.nil? && child2.nil?
        child1
      elsif child1.nil? && !child2.nil?
        child2
      else
        nil
      end
    end

    # compatibility with ac-library

    def set(index : Int, value : T)
      self.[]=(index, value)
    end

    def get(index : Int)
      self.[](index)
    end

    def prod(left : Int, right : Int)
      self.[](left...right)
    end

    def all_prod
      self.[](0...@segments.size)
    end
  end
end