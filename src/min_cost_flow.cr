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

require "./priority_queue.cr"

module AtCoder
  # Implements [atcoder::mcf_graph](https://atcoder.github.io/ac-library/master/document_en/mincostflow.html).
  #
  # ```
  # flow = AtCoder::MinCostFlow.new(5)
  # flow.add_edge(0, 1, 30, 3)
  # flow.add_edge(0, 2, 60, 9)
  # flow.add_edge(1, 2, 40, 5)
  # flow.add_edge(1, 3, 50, 7)
  # flow.add_edge(2, 3, 20, 8)
  # flow.add_edge(2, 4, 50, 6)
  # flow.add_edge(3, 4, 60, 7)
  # flow.flow(0, 4, 70) # => {70, 1080}
  # ```
  class MinCostFlow
    # An edge of the residual graph.
    private class Edge
      getter to : Int64
      getter reverse_index : Int64
      property capacity : Int64
      getter cost : Int64

      def initialize(@to, @capacity, @cost, @reverse_index)
      end
    end

    # Number of nodes
    getter size : Int64

    # Implements atcoder::mcf_graph g(n).
    def initialize(size)
      @size = size.to_i64
      # Residual graph. Each edge holds the index of its reverse edge in
      # the adjacency list of its destination, so parallel edges and
      # edges in the opposite direction never collide.
      @adjacencies = Array(Array(Edge)).new(@size) { [] of Edge }
      # Position of the i-th added edge: {from, index in @adjacencies[from]}
      @positions = [] of {Int64, Int64}
      # Dual (potential) of each node. `@duals[target] - @duals[start]` is the
      # cost of the current shortest path from start to target. It is kept between calls
      # of `#slope` so that the reduced costs of the residual graph stay
      # non-negative after a flow is pushed.
      @duals = Array(Int64).new(@size, 0_i64)
    end

    # Implements atcoder::mcf_graph.add_edge(from, to, capacity, cost).
    #
    # Returns the index of the added edge.
    def add_edge(from, to, capacity, cost)
      from = from.to_i64
      to = to.to_i64
      from_index = @adjacencies[from].size.to_i64
      to_index = @adjacencies[to].size.to_i64
      # Self-loop: the reverse edge is pushed right after the forward edge.
      to_index += 1 if from == to

      @adjacencies[from] << Edge.new(to, capacity.to_i64, cost.to_i64, to_index)
      @adjacencies[to] << Edge.new(from, 0_i64, -cost.to_i64, from_index)

      @positions << {from, from_index}
      @positions.size.to_i64 - 1
    end

    # Implements atcoder::mcf_graph.slope(start, target, flow_limit).
    def slope(start, target, flow_limit : Int | Nil = nil)
      raise ArgumentError.new("start and target cannot be the same") if start == target

      start = start.to_i64
      target = target.to_i64
      flow_limit = flow_limit.nil? ? Int64::MAX : flow_limit.to_i64

      dists = Array(Int64).new(@size, Int64::MAX)
      visited = Array(Bool).new(@size, false)
      prev_nodes = Array(Int64).new(@size, -1_i64)
      prev_edges = Array(Int64).new(@size, -1_i64)

      flow = 0_i64
      cost = 0_i64
      prev_cost_per_flow = -1_i64
      result = [{0_i64, 0_i64}]

      while flow < flow_limit
        break unless refine_duals(start, target, dists, visited, prev_nodes, prev_edges)

        # Find the bottleneck capacity of the shortest path
        capacity = flow_limit - flow
        node = target
        until node == start
          capacity = min(capacity, @adjacencies[prev_nodes[node]][prev_edges[node]].capacity)
          node = prev_nodes[node]
        end

        node = target
        until node == start
          edge = @adjacencies[prev_nodes[node]][prev_edges[node]]
          edge.capacity -= capacity
          @adjacencies[node][edge.reverse_index].capacity += capacity
          node = prev_nodes[node]
        end

        cost_per_flow = @duals[target] - @duals[start]
        flow += capacity
        cost += capacity * cost_per_flow
        result.pop if prev_cost_per_flow == cost_per_flow
        result << {flow, cost}
        prev_cost_per_flow = cost_per_flow
      end

      result
    end

    # Implements atcoder::mcf_graph.flow(start, target, flow_limit).
    def flow(start, target, flow_limit : Int | Nil = nil)
      slope(start, target, flow_limit).last
    end

    # FIXME: Unimplemented
    def get_edge(i)
      raise NotImplementedError.new
    end

    # FIXME: Unimplemented
    def edges
      raise NotImplementedError.new
    end

    # Runs Dijkstra's algorithm on the residual graph with reduced costs and
    # updates the duals. Returns false if target is unreachable.
    private def refine_duals(start, target, dists, visited, prev_nodes, prev_edges)
      dists.fill(Int64::MAX)
      visited.fill(false)

      queue = PriorityQueue({Int64, Int64}).new { |a, b| a[0] >= b[0] }
      dists[start] = 0_i64
      queue << {0_i64, start}

      while item = queue.pop
        node = item[1]
        next if visited[node]
        visited[node] = true
        break if node == target

        dist = dists[node]
        dual = @duals[node]
        @adjacencies[node].each_with_index do |edge, i|
          next if edge.capacity == 0
          # Reduced cost, which is non-negative
          reduced_cost = edge.cost - @duals[edge.to] + dual
          if dists[edge.to] - dist > reduced_cost
            dists[edge.to] = dist + reduced_cost
            prev_nodes[edge.to] = node
            prev_edges[edge.to] = i.to_i64
            queue << {dists[edge.to], edge.to}
          end
        end
      end

      return false unless visited[target]

      target_dist = dists[target]
      @size.times do |v|
        next unless visited[v]
        @duals[v] -= target_dist - dists[v]
      end

      true
    end

    @[AlwaysInline]
    private def min(a, b)
      a > b ? b : a
    end
  end
end
