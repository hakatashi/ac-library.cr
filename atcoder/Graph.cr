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

require "./PriorityQueue.cr"

module AtCoder
  class Graph(NodeInfo, EdgeInfo)
    getter visited : Set(Int64)

    def initialize(@nodes : Array(NodeInfo))
      @size = @nodes.size.to_i64
      @edges = [] of EdgeInfo
      @adjacencies = Array(Array({Int64, Int64})).new(@size) { [] of {Int64, Int64} }
      @visited = Set(Int64).new
    end

    def initialize(@size : Int64, initial_node : NodeInfo = nil)
      @nodes = Array(NodeInfo).new(@size, initial_node)
      @edges = [] of EdgeInfo
      @adjacencies = Array(Array({Int64, Int64})).new(@size) { [] of {Int64, Int64} }
      @visited = Set(Int64).new
    end

    # Performs Dijkstra's Algorithm to calculate the distance of each node from `start_node`.
    # To use this method, `EdgeInfo` must implement `.zero` and `#-` and `#+(EdgeInfo)` and `#>(EdgeInfo)`.
    def dijkstra(start_node)
      dist = Array(EdgeInfo | Nil).new(@size, nil)
      dist[start_node] = EdgeInfo.zero

      prev_nodes = Array(Int64 | Nil).new(@size, nil)

      queue = AtCoder::PriorityQueue({EdgeInfo, Int64}).new {|(d, v)| -d}
      queue << {EdgeInfo.zero, start_node.to_i64}

      until queue.empty?
        d, v = queue.pop.not_nil!
        current_dist = dist[v].not_nil!
        next if d > current_dist

        @adjacencies[v].each do |(to, edge_id)|
          cost = @edges[edge_id]
          target_dist = dist[to]
          if target_dist.nil? || target_dist > current_dist + cost
            dist[to] = current_dist + cost
            prev_nodes[to] = v
            queue << {current_dist, to}
          end
        end
      end

      Array({dist: EdgeInfo | Nil, prev: Int64 | Nil}).new(@size) do |i|
        {dist: dist[i], prev: prev_nodes[i]}
      end
    end

    def dfs(node : Int64, initial_value : T, &block : Int64, T, NamedTuple(
      node: Int64,
      node_info: NodeInfo | Nil,
      edge: Int64 | Nil,
      edge_info: EdgeInfo | Nil,
      parent: Int64,
    ), (T ->) ->) forall T
      @visited = Set(Int64).new
      info = {
        node: node,
        node_info: @nodes[node].as(NodeInfo | Nil),
        edge: nil.as(Int64 | Nil),
        edge_info: nil.as(EdgeInfo | Nil),
        parent: -1_i64,
      }
      block.call(node, initial_value, info, ->(new_value : T) {
        dfs(node, -1_i64, new_value, &block)
      })
    end

    private def dfs(node : Int64, parent : Int64, value : T, &block : Int64, T, NamedTuple(
      node: Int64,
      node_info: NodeInfo | Nil,
      edge: Int64 | Nil,
      edge_info: EdgeInfo | Nil,
      parent: Int64,
    ), (T ->) ->) forall T
      @visited << node
      @adjacencies[node].each do |(child, edge)|
        next if @visited.includes?(child)
        info = {
          node: child,
          node_info: @nodes[child].as(NodeInfo | Nil),
          edge: edge.as(Int64 | Nil),
          edge_info: @edges[edge].as(EdgeInfo | Nil),
          parent: node,
        }
        block.call(child, value, info, ->(new_value : T) {
          dfs(child, node, new_value, &block)
        })
      end
    end
  end

  class DirectedGraph(NodeInfo, EdgeInfo) < Graph(NodeInfo, EdgeInfo)
    def add_edge(from, to, edge : EdgeInfo = 1_i64)
      @edges << edge
      edge_id = @edges.size.to_i64 - 1
      @adjacencies[from] << {to.to_i64, edge_id}
      edge_id
    end
  end

  class UndirectedGraph(NodeInfo, EdgeInfo) < Graph(NodeInfo, EdgeInfo)
    def add_edge(a : Int64, b : Int64, edge : EdgeInfo = 1_i64)
      @edges << edge
      edge_id = @edges.size.to_i64 - 1
      @adjacencies[a] << {b.to_i64, edge_id}
      @adjacencies[b] << {a.to_i64, edge_id}
      edge_id
    end
  end

  class Tree(NodeInfo, EdgeInfo) < UndirectedGraph(NodeInfo, EdgeInfo)
    def diameter
      @farthest_node = -1_i64
      @farthest_depth = 0_i64
      dfs(0_i64, 0_i64) do |node, depth, info, callback|
        weight = info[:edge_info]
        depth += weight.nil? ? 0 : weight
        if @farthest_depth.not_nil! < depth
          @farthest_node = node
          @farthest_depth = depth
        end
        callback.call(depth)
      end

      start_node = @farthest_node.not_nil!
      @farthest_node = -1_i64
      @farthest_depth = 0_i64
      @parents = Array(Int64).new(@size, -1_i64)
      dfs(start_node, 0_i64) do |node, depth, info, callback|
        weight = info[:edge_info]
        depth += weight.nil? ? 0 : weight
        @parents.not_nil![node] = info[:parent]
        if @farthest_depth.not_nil! < depth
          @farthest_node = node
          @farthest_depth = depth
        end
        callback.call(depth)
      end

      {@farthest_depth.not_nil!, start_node, @farthest_node.not_nil!, @parents.not_nil!}
    end
  end
end
