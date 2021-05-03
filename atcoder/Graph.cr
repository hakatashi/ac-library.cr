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
  class Graph
    getter adjacencies : Array(Array({Int64, Int64}))
    INF = 1_000_000_000_000_000_000_i64

    def initialize(@size : Int64)
      @adjacencies = Array(Array({Int64, Int64})).new(@size) { [] of {Int64, Int64} }
    end

    def dijkstra(start_node)
      dist = Array(Int64 | Nil).new(@size, nil)
      dist[start_node] = 0_i64

      prev_nodes = Array(Int64 | Nil).new(@size, nil)

      queue = AtCoder::PriorityQueue({Int64, Int64}).new {|(d, v)| -d}
      queue << {0_i64, start_node.to_i64}

      until queue.empty?
        d, v = queue.pop.not_nil!
        current_dist = dist[v].not_nil!
        next if current_dist < d

        @adjacencies[v].each do |(to, cost)|
          target_dist = dist[to]
          if target_dist.nil? || target_dist > current_dist + cost
            dist[to] = current_dist + cost
            prev_nodes[to] = v
            queue << {current_dist, to}
          end
        end
      end

      Array({dist: Int64 | Nil, prev: Int64 | Nil}).new(@size) do |i|
        {dist: dist[i], prev: prev_nodes[i]}
      end
    end
  end

  class DirectedGraph < Graph
    def add_edge(from, to, weight = 1_i64)
      @adjacencies[from] << {to.to_i64, weight}
    end
  end

  class UndirectedGraph < Graph
    def add_edge(a : Int64, b : Int64, weight = 1_i64)
      @adjacencies[a] << {b.to_i64, weight}
      @adjacencies[b] << {a.to_i64, weight}
    end
  end
end
