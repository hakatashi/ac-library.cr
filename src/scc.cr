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
  # Implements [atcoder::scc_graph](https://atcoder.github.io/ac-library/master/document_en/scc.html).
  #
  # ```
  # scc = AtCoder::SCC.new(3_i64)
  # scc.add_edge(0, 1)
  # scc.add_edge(1, 0)
  # scc.add_edge(2, 0)
  # scc.scc # => [Set{2}, Set{0, 1}]
  # ```
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

    # Implements atcoder::scc_graph.add_edge(from, to).
    def add_edge(from, to)
      @adjacencies[from][:out] << to.to_i64
      @adjacencies[to][:in] << from.to_i64
    end

    private def dfs(start)
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

    private def reverse_dfs(start)
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

    # Implements atcoder::scc_graph.scc().
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
end
