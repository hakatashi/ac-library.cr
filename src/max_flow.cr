# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
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
  # mf.flow(0, 2)  # => 3
  # mf.min_cut(0)  # => [true, true, false]
  # mf.get_edge(0) # => AtCoder::MaxFlow::EdgeInfo(@from=0, @to=1, @cap=3, @flow=1)
  # ```
  class MaxFlow
    class Edge
      getter to : Int64
      getter reverse_index : Int64
      property capacity : Int64

      def initialize(@to, @capacity, @reverse_index)
      end
    end

    # An edge as seen by the user: the original capacity `cap` and the current `flow`.
    #
    # Returned by `#get_edge` and `#edges`, in the same way as ACL's `mf_graph::edge`.
    record EdgeInfo, from : Int64, to : Int64, cap : Int64, flow : Int64

    # Number of nodes
    getter size : Int64

    # Adjacency list
    getter adjacencies : Array(Array(Edge))

    getter depths : Array(Int64)

    # Number of visited adjacencies for each nodes
    getter visit_counts : Array(Int64)

    # `{from, index in @adjacencies[from]}` of each edge, in order of addition
    @positions : Array({Int64, Int64})

    @path : Array(Int64)
    @queue : Array(Int64)

    def initialize(@size)
      @adjacencies = Array(Array(Edge)).new(@size) { [] of Edge }
      @depths = Array(Int64).new(@size, -1_i64)
      @visit_counts = Array(Int64).new(@size, 0_i64)
      @positions = Array({Int64, Int64}).new
      @path = Array(Int64).new
      @queue = Array(Int64).new(@size, 0_i64)
    end

    # Implements atcoder::mf_graph.add_edge(from, to, capacity).
    #
    # Returns the index of the added edge (0-indexed, in order of addition).
    def add_edge(from, to, capacity)
      from = from.to_i64
      to = to.to_i64
      capacity = capacity.to_i64
      raise IndexError.new unless 0 <= from < @size && 0 <= to < @size
      raise ArgumentError.new("capacity must be non-negative") if capacity < 0

      from_index = @adjacencies[from].size.to_i64
      to_index = @adjacencies[to].size.to_i64
      # Self-loop: the reverse edge is pushed right after the forward edge.
      to_index += 1 if from == to

      @adjacencies[from] << Edge.new(to, capacity, to_index)
      @adjacencies[to] << Edge.new(from, 0_i64, from_index)

      @positions << {from, from_index}
      @positions.size.to_i64 - 1
    end

    # Implements atcoder::mf_graph.flow(start, target).
    def flow(start, target)
      start_i64 = start.to_i64
      target_i64 = target.to_i64

      raise IndexError.new unless 0 <= start_i64 < @size && 0 <= target_i64 < @size
      return 0_i64 if start_i64 == target_i64

      flow = 0_i64

      loop do
        bfs(start_i64, target_i64)
        if @depths[target_i64] < 0
          return flow
        end

        @visit_counts.fill(0_i64)
        pushed = dfs(target_i64, start_i64)
        break if pushed == 0
        flow += pushed
      end

      flow
    end

    # Implements atcoder::mf_graph.min_cut(start).
    def min_cut(start) : Array(Bool)
      start_i64 = start.to_i64
      raise IndexError.new unless 0 <= start_i64 < @size

      visited = Array(Bool).new(@size, false)
      qh = 0
      qt = 0

      visited[start_i64] = true
      @queue[qt] = start_i64
      qt += 1

      while qh < qt
        node = @queue[qh]
        qh += 1

        @adjacencies[node].each do |edge|
          to = edge.to
          if edge.capacity > 0 && !visited[to]
            visited[to] = true
            @queue[qt] = to
            qt += 1
          end
        end
      end

      visited
    end

    # Implements atcoder::mf_graph.get_edge(i).
    #
    # Returns an `EdgeInfo` with the original capacity `cap` and the current `flow`.
    # Raises `IndexError` if `i` is not a valid edge index.
    def get_edge(i) : EdgeInfo
      from, index = @positions[check_edge_index(i)]
      edge = @adjacencies[from][index]
      rev_edge = @adjacencies[edge.to][edge.reverse_index]
      EdgeInfo.new(from, edge.to, edge.capacity + rev_edge.capacity, rev_edge.capacity)
    end

    # Implements atcoder::mf_graph.edges().
    #
    # Returns all edges in order of addition, in the same form as `#get_edge`.
    def edges : Array(EdgeInfo)
      Array(EdgeInfo).new(@positions.size) { |i| get_edge(i) }
    end

    # Implements atcoder::mf_graph.change_edge(i, new_cap, new_flow).
    #
    # Changes the capacity and the flow of the edge `i`. This does not change the flow
    # of the other edges, so the result may not be a valid flow until `#flow` is called.
    # Raises `ArgumentError` unless `0 <= new_flow <= new_cap`.
    def change_edge(i, new_capacity, new_flow) : Nil
      position = @positions[check_edge_index(i)]
      new_capacity = new_capacity.to_i64
      new_flow = new_flow.to_i64
      raise ArgumentError.new("flow must satisfy 0 <= flow <= capacity") unless 0 <= new_flow <= new_capacity

      from, index = position
      edge = @adjacencies[from][index]
      rev_edge = @adjacencies[edge.to][edge.reverse_index]
      edge.capacity = new_capacity - new_flow
      rev_edge.capacity = new_flow
    end

    private def check_edge_index(i) : Int32
      i = i.to_i64
      raise IndexError.new unless 0 <= i < @positions.size
      i.to_i32
    end

    private def bfs(start : Int64, target : Int64)
      @depths.fill(-1_i64)
      depths_ptr = @depths.to_unsafe
      q_ptr = @queue.to_unsafe

      qh = 0
      qt = 0

      depths_ptr[start] = 0_i64
      q_ptr[qt] = start
      qt += 1

      while qh < qt
        node = q_ptr[qh]
        qh += 1

        d_next = depths_ptr[node] + 1_i64
        edges = @adjacencies.unsafe_fetch(node)
        edges_ptr = edges.to_unsafe
        count = edges.size

        count.times do |i|
          edge = edges_ptr[i]
          to = edge.to
          if edge.capacity > 0 && depths_ptr[to] < 0
            depths_ptr[to] = d_next
            if to == target
              return
            end
            q_ptr[qt] = to
            qt += 1
          end
        end
      end
    end

    # Pushes blocking flow along augmenting paths on the level graph from `target`
    # back to `start`.
    #
    # Following ACL's Dinic implementation, searching in reverse from `target`
    # to `start` drastically prunes the search space on bipartite matching networks,
    # where the sink `target` only connects to unmatched vertices in the residual
    # network.
    #
    # To prevent stack overflow on deep paths (e.g. 200,000+ vertices), this is
    # implemented iteratively with an explicit path stack `@path`. When a path
    # to `start` is found, the bottleneck flow is pushed and `@path` is retracted
    # only up to the first saturated edge, continuing the search without restarting
    # from scratch.
    private def dfs(target : Int64, start : Int64) : Int64
      total_flow = 0_i64
      path = @path
      path.clear
      path << target

      until path.empty?
        node = path.last

        if node == start
          flow = Int64::MAX
          (path.size - 1).times do |i|
            v = path[i]
            edge = @adjacencies[v][@visit_counts[v]]
            u = edge.to
            rev_edge = @adjacencies[u][edge.reverse_index]
            flow = min(flow, rev_edge.capacity)
          end

          (path.size - 1).times do |i|
            v = path[i]
            edge = @adjacencies[v][@visit_counts[v]]
            u = edge.to
            rev_edge = @adjacencies[u][edge.reverse_index]
            rev_edge.capacity -= flow
            edge.capacity += flow
          end

          total_flow += flow

          bottleneck_idx = -1
          (path.size - 1).times do |i|
            v = path[i]
            edge = @adjacencies[v][@visit_counts[v]]
            u = edge.to
            rev_edge = @adjacencies[u][edge.reverse_index]
            if rev_edge.capacity == 0
              bottleneck_idx = i
              break
            end
          end

          pop_count = path.size - 1 - bottleneck_idx
          pop_count.times { path.pop }

          @visit_counts[path.last] += 1
          next
        end

        edges = @adjacencies[node]
        advanced = false
        d_node = @depths[node]

        while @visit_counts[node] < edges.size
          edge = edges[@visit_counts[node]]
          u = edge.to
          if @depths[u] >= 0 && d_node > @depths[u]
            rev_edge = @adjacencies[u][edge.reverse_index]
            if rev_edge.capacity > 0
              path << u
              advanced = true
              break
            end
          end
          @visit_counts[node] += 1
        end

        unless advanced
          @depths[node] = @size
          path.pop
          @visit_counts[path.last] += 1 unless path.empty?
        end
      end

      total_flow
    end

    @[AlwaysInline]
    private def min(a, b)
      a > b ? b : a
    end
  end
end
