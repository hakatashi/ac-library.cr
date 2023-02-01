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

require "./scc.cr"

module AtCoder
  # Implements [atcoder::two_sat](https://atcoder.github.io/ac-library/master/document_en/twosat.html)
  #
  # ```
  # twosat = AtCoder::TwoSat.new(2_i64)
  # twosat.add_clause(0, true, 1, false)
  # twosat.add_clause(1, true, 0, false)
  # twosat.add_clause(0, false, 1, false)
  # twosat.satisfiable? # => true
  # twosat.answer       # => [false, false]
  # ```
  class TwoSat
    getter size : Int64

    class NotSatisfiableError < Exception
      def initialize
        super("The formula is not satisfiable")
      end
    end

    def initialize(@size)
      @scc = AtCoder::SCC.new(@size * 2)
      @solved = false
      @satisfiable = false
      @group_list = Array(Int64).new(@size * 2, 0_i64)
    end

    @[AlwaysInline]
    private def var(i, f)
      if f
        i.to_i64
      else
        i.to_i64 + @size
      end
    end

    # Implements atcoder::two_sat.add_clause(i, f, j, g).
    def add_clause(i, f, j, g)
      @scc.add_edge(var(i, !f), var(j, g))
      @scc.add_edge(var(j, !g), var(i, f))
    end

    # Implements atcoder::two_sat.satisfiable().
    def satisfiable?
      @satisfiable = false

      groups = @scc.scc
      @group_list = Array(Int64).new(@size * 2, 0_i64)
      groups.each_with_index do |group, i|
        group.each do |item|
          @group_list[item] = i.to_i64
        end
      end

      @size.times do |i|
        if @group_list[i] == @group_list[i + @size]
          return false
        end
      end

      @satisfiable = true
    end

    # Implements atcoder::two_sat.answer().
    #
    # This method will raise `NotSatisfiableError` if it's not satisfiable.
    def answer
      unless @satisfiable
        raise NotSatisfiableError.new
      end

      Array(Bool).new(@size) do |i|
        @group_list.not_nil![i] > @group_list.not_nil![i + @size]
      end
    end
  end
end
