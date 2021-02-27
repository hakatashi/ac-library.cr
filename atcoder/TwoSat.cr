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
  class TwoSat
    class SCC
      alias Adjacency = NamedTuple(in: Array(Int64), out: Array(Int64))

      getter size : Int64
      getter adjacencies : Array(Adjacency)

      def initialize(@size)
        @adjacencies = Array(Adjacency).new(@size) { {in: [] of Int64, out: [] of Int64} }

        @topological_order = Array(Int64).new(@size)
        @visit_counts = Array(Int64).new(@size, 0_i64)
        @visited = Set(Int64).new
        @stack = Deque(Int64).new
        @groups = Array(Set(Int64)).new
      end

      def add_edge(from, to)
        @adjacencies[from][:out] << to.to_i64
        @adjacencies[to][:in] << from.to_i64
      end

      def dfs(start)
        @stack << start
        @visited << start

        until @stack.empty?
          node = @stack.last
          children = @adjacencies[node][:out]

          if @visit_counts[node] < children.size
            child = children[@visit_counts[node]]
            @visit_counts[node] += 1

            unless @visited.includes?(child)
              @visited << child
              @stack << child
            end
          else
            @topological_order << node
            @stack.pop
          end
        end
      end

      def reverse_dfs(start)
        @stack << start
        @visited << start
        group = Set{start}

        until @stack.empty?
          node = @stack.pop
          children = @adjacencies[node][:in]

          children.each do |child|
            unless @visited.includes?(child)
              @stack << child
              @visited << child
              group << child
            end
          end
        end

        @groups << group
      end

      def scc
        @visited = Set(Int64).new
        @stack = Deque(Int64).new
        @visit_counts = Array(Int64).new(@size, 0_i64)
        @topological_order = Array(Int64).new(@size)
        @groups = Array(Set(Int64)).new

        @size.times do |node|
          unless @visited.includes?(node)
            dfs(node)
          end
        end

        @visited = Set(Int64).new

        @topological_order.reverse_each do |node|
          unless @visited.includes?(node)
            reverse_dfs(node)
          end
        end

        @groups
      end
    end

    getter size : Int64

    class NotSatisfiableError < Exception
      def initialize
        super("The formula is not satisfiable")
      end
    end

    def initialize(@size)
      @scc = SCC.new(@size * 2)
      @solved = false
      @satisfiable = false
      @group_list = Array(Int64).new(@size * 2, 0_i64)
    end

    @[AlwaysInline]
    def var(i, f)
      if f
        i.to_i64
      else
        i.to_i64 + @size
      end
    end

    def add_clause(i, f, j, g)
      @scc.add_edge(var(i, !f), var(j, g))
      @scc.add_edge(var(j, !g), var(i, f))
    end

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
