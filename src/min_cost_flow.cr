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

require "./graph.cr"

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
    private record EdgeInfo, capacity : Int64, cost : Int64 | Nil do
      def self.zero
        new(Int64::MAX, 0_i64)
      end

      def +(edge : EdgeInfo)
        from_cost = @cost
        to_cost = edge.cost
        if from_cost.nil? || to_cost.nil?
          return self.class.new(0_i64, nil)
        end

        self.class.new(min(@capacity, edge.capacity), from_cost + to_cost)
      end

      def >(edge : EdgeInfo)
        from_dist = dist
        to_dist = edge.dist

        return true if from_dist.nil?
        return false if to_dist.nil?

        from_dist > to_dist
      end

      def dist
        return nil if @capacity == 0
        @cost
      end

      @[AlwaysInline]
      private def min(a, b)
        a > b ? b : a
      end
    end

    # Implements atcoder::mcf_graph g(n).
    def initialize(@size : Int64)
      @graph = AtCoder::DirectedGraph(Nil, EdgeInfo).new(@size)
      @dists = Array(Int64 | Nil).new(@size, 0_i64)
      @edges = [] of {Int64, Int64}
    end

    # Implements atcoder::mcf_graph.add_edge(from, to, capacity, cost).
    def add_edge(from, to, capacity, cost)
      @graph.add_edge(from, to, EdgeInfo.new(capacity.to_i64, cost.to_i64))
      @graph.add_edge(to, from, EdgeInfo.new(0_i64, -cost.to_i64))
      @edges << {from.to_i64, to.to_i64}
    end

    private def increment_edge_cost(from, to, cost_diff)
      edge = @graph.get_edge(from, to)
      @graph.update_edge(from, to, edge + EdgeInfo.new(edge.capacity, cost_diff))
    end

    private def increment_edge_capacity(from, to, capacity_diff)
      edge = @graph.get_edge(from, to)
      @graph.update_edge(from, to, EdgeInfo.new(edge.capacity + capacity_diff, edge.cost))
    end

    # Implements atcoder::mcf_graph.slope(start, target, flow_limit).
    # ameba:disable Metrics/CyclomaticComplexity
    def slope(start, target, flow_limit : Int | Nil = nil)
      raise ArgumentError.new("start and target cannot be the same") if start == target

      flow_points = [] of {Int64, Int64}

      current_cost = 0_i64

      flowed_capacity = 0_i64
      min_cost = 0_i64

      until flowed_capacity == flow_limit
        nodes = @graph.dijkstra(start)

        target_dist = nodes[target][:dist]

        if target_dist.nil? || target_dist.capacity == 0
          break
        end

        capacity = target_dist.capacity

        # Update edge capacities on the path from start to target
        last_node = target
        until last_node == start
          prev_node = nodes[last_node][:prev].not_nil!

          increment_edge_capacity(prev_node, last_node, -capacity)
          increment_edge_capacity(last_node, prev_node, capacity)

          last_node = prev_node
        end

        # Update edge costs
        @edges.each do |from, to|
          from_dist = nodes[from][:dist]
          to_dist = nodes[to][:dist]

          next if from_dist.nil? || to_dist.nil?
          next if from_dist.cost.nil? || to_dist.cost.nil?

          dist = to_dist.cost.not_nil! - from_dist.cost.not_nil!

          increment_edge_cost(from, to, -dist)
          increment_edge_cost(to, from, dist)
        end

        # Update distants
        nodes.each_with_index do |node, i|
          dist = node[:dist]
          if dist.nil? || @dists[i].nil? || dist.not_nil!.cost.nil?
            @dists[i] = nil
          else
            @dists[i] = @dists[i].not_nil! + dist.not_nil!.cost.not_nil!
          end
        end

        new_cost = @dists[target].not_nil!
        if flow_limit.nil?
          new_capacity = capacity
        else
          new_capacity = min(capacity, flow_limit - flowed_capacity)
        end

        if new_cost != current_cost
          if current_cost == 0 && flowed_capacity != 0
            flow_points << {0_i64, 0_i64}
          end
          flow_points << {flowed_capacity, min_cost}
        end

        min_cost += new_cost * new_capacity
        flowed_capacity += new_capacity
        current_cost = new_cost
      end

      flow_points << {flowed_capacity, min_cost}

      flow_points
    end

    # Implements atcoder::mcf_graph.flow(start, target, flow_limit).
    def flow(start, target, flow_limit : Int | Nil = nil)
      flow_points = slope(start, target, flow_limit)
      flow_points.last
    end

    @[AlwaysInline]
    private def min(a, b)
      a > b ? b : a
    end

    delegate :size, to: @graph
  end
end
