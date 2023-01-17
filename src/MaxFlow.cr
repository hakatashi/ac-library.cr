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
  # Implements [atcoder::mf_graph](https://atcoder.github.io/ac-library/master/document_en/maxflow.html).
  # `Cap` is always `Int64`.
  #
  # ```
  # mf = AtCoder::MaxFlow.new(3)
  # mf.add_edge(0, 1, 3)
  # mf.add_edge(1, 2, 1)
  # mf.add_edge(0, 2, 2)
  # mf.flow(0, 2) # => 3
  # ```
  class MaxFlow
    class Edge
      getter to : Int64
      getter reverse_index : Int64
      property capacity : Int64

      def initialize(@to, @capacity, @reverse_index)
      end
    end

    # Number of nodes
    getter size : Int64

    # Adjacency list
    getter adjacencies : Array(Array(Edge))

    getter depths : Array(Int64)

    # Number of visited adjacencies for each nodes
    getter visit_counts : Array(Int64)

    def initialize(@size)
      @adjacencies = Array(Array(Edge)).new(@size) { [] of Edge }
      @depths = Array(Int64).new(@size, -1_i64)
      @visit_counts = Array(Int64).new(@size, 0_i64)
    end

    # Implements atcoder::mf_graph.add_edge(from, to, capacity).
    def add_edge(from, to, capacity)
      from_index = @adjacencies[from].size.to_i64
      to_index = @adjacencies[to].size.to_i64

      @adjacencies[from] << Edge.new(to.to_i64, capacity.to_i64, to_index)
      @adjacencies[to] << Edge.new(from.to_i64, 0_i64, from_index)
    end

    # Implements atcoder::mf_graph.flow(start, target).
    def flow(start, target)
      flow = 0_i64

      loop do
        bfs(start)
        if @depths[target] < 0
          return flow
        end

        @visit_counts.fill(0_i64)
        while (flowed = dfs(start, target, Int64::MAX)) > 0
          flow += flowed
        end
      end
    end

    # FIXME: Unimplemented
    def min_cut
      raise NotImplementedError.new
    end

    # FIXME: Unimplemented
    def get_edge
      raise NotImplementedError.new
    end

    # FIXME: Unimplemented
    def edges
      raise NotImplementedError.new
    end

    # FIXME: Unimplemented
    def change_edge
      raise NotImplementedError.new
    end

    private def bfs(start)
      @depths.fill(-1_i64)
      queue = Deque(Int64).new

      @depths[start] = 0_i64
      queue << start.to_i64
      until queue.empty?
        node = queue.shift

        @adjacencies[node].each do |edge|
          if edge.capacity > 0 && @depths[edge.to] < 0
            @depths[edge.to] = @depths[node] + 1
            queue << edge.to
          end
        end
      end
    end

    private def dfs(node, target, flow)
      return flow if node == target

      edges = @adjacencies[node]
      while @visit_counts[node] < edges.size
        edge = edges[@visit_counts[node]]
        if edge.capacity > 0 && @depths[node] < @depths[edge.to]
          flowed = dfs(edge.to, target, min(flow, edge.capacity))

          if flowed > 0
            edge.capacity -= flowed
            @adjacencies[edge.to][edge.reverse_index].capacity += flowed
            return flowed
          end
        end

        @visit_counts[node] += 1
      end

      0_i64
    end

    @[AlwaysInline]
    private def min(a, b)
      a > b ? b : a
    end
  end
end
