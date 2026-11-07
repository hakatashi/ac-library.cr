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

    # Vertices are stored as `Int32` internally to save memory and time
    # (the number of vertices never exceeds `Int32::MAX` in practice).
    @from : Array(Int32)
    @to : Array(Int32)

    def initialize(size)
      @size = size.to_i64
      raise ArgumentError.new("Too many vertices: #{@size}") if @size > Int32::MAX
      @from = [] of Int32
      @to = [] of Int32
    end

    # Implements atcoder::scc_graph.add_edge(from, to).
    def add_edge(from, to)
      from = from.to_i64
      to = to.to_i64
      raise IndexError.new unless 0 <= from < @size && 0 <= to < @size
      @from << from.to_i32
      @to << to.to_i32
    end

    # Returns the in/out adjacency lists of each vertex.
    #
    # Kept for compatibility. It is built on every call, so avoid calling it in hot paths.
    def adjacencies : Array(Adjacency)
      adjacencies = Array(Adjacency).new(@size) { {in: [] of Int64, out: [] of Int64} }
      @from.each_with_index do |from, i|
        to = @to.unsafe_fetch(i)
        adjacencies[from][:out] << to.to_i64
        adjacencies[to][:in] << from.to_i64
      end
      adjacencies
    end

    # Calculates SCCs by Tarjan's algorithm, as `internal::scc_graph::scc_ids()` of ACL.
    #
    # Returns the number of groups and the group id of each vertex.
    # Group ids are in topological order.
    protected def scc_ids : {Int32, Array(Int32)}
      n = @size.to_i32

      # CSR representation of the out-edges
      start = Array(Int32).new(n + 1, 0)
      @from.each { |from| start[from + 1] += 1 }
      n.times { |i| start[i + 1] += start[i] }
      elist = Array(Int32).new(@to.size, 0)
      counter = start.dup
      @from.each_with_index do |from, i|
        elist[counter[from]] = @to.unsafe_fetch(i)
        counter[from] += 1
      end

      now_ord = 0
      group_num = 0
      ord = Array(Int32).new(n, -1)
      low = Array(Int32).new(n, 0)
      ids = Array(Int32).new(n, 0)
      visited = Array(Int32).new(n)
      # The DFS is iterative to avoid stack overflow on deep graphs.
      # `counter[v]` is reused as the index of the next edge to scan from `v`.
      call_stack = Array(Int32).new(n)

      n.times do |root|
        next if ord[root] != -1

        ord[root] = low[root] = now_ord
        now_ord += 1
        visited << root
        call_stack << root
        counter[root] = start[root]

        until call_stack.empty?
          v = call_stack.last
          if counter[v] < start[v + 1]
            to = elist[counter[v]]
            counter[v] += 1
            if ord[to] == -1
              ord[to] = low[to] = now_ord
              now_ord += 1
              visited << to
              call_stack << to
              counter[to] = start[to]
            elsif ord[to] < low[v]
              low[v] = ord[to]
            end
          else
            call_stack.pop
            if low[v] == ord[v]
              loop do
                u = visited.pop
                ord[u] = n
                ids[u] = group_num
                break if u == v
              end
              group_num += 1
            end
            unless call_stack.empty?
              parent = call_stack.last
              low[parent] = low[v] if low[v] < low[parent]
            end
          end
        end
      end

      # Tarjan's algorithm finds groups in reverse topological order.
      n.times { |i| ids[i] = group_num - 1 - ids[i] }
      {group_num, ids}
    end

    # Implements atcoder::scc_graph.scc().
    #
    # Unlike ACL, each group is a `Set` instead of an array.
    def scc
      group_num, ids = scc_ids
      # Passing `initial_capacity` to `Set.new` turned out to be slower.
      groups = Array(Set(Int64)).new(group_num) { Set(Int64).new }
      ids.each_with_index { |id, v| groups[id] << v.to_i64 }
      groups
    end
  end
end
