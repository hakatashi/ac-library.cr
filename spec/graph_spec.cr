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

require "../src/graph.cr"
require "spec"

alias DirectedGraph = AtCoder::DirectedGraph
alias UndirectedGraph = AtCoder::UndirectedGraph
alias Tree = AtCoder::Tree

# Single-source shortest distances by the Bellman–Ford algorithm.
private def naive_distances(n, edges, start, directed)
  dist = Array(Int64?).new(n, nil)
  dist[start] = 0_i64
  arcs = directed ? edges : edges.flat_map { |(a, b, c)| [{a, b, c}, {b, a, c}] }
  n.times do
    arcs.each do |(from, to, cost)|
      from_dist = dist[from]
      next if from_dist.nil?
      to_dist = dist[to]
      dist[to] = from_dist + cost if to_dist.nil? || to_dist > from_dist + cost
    end
  end
  dist
end

# Random edges with distinct endpoint pairs, since adding the same pair twice overwrites the edge.
private def random_edges(rng, n, m, directed)
  edges = {} of {Int32, Int32} => Int64
  m.times do
    a, b = rng.rand(n), rng.rand(n)
    next if a == b
    a, b = b, a if !directed && a > b
    edges[{a, b}] = rng.rand(0_i64..10_i64)
  end
  edges.map { |(a, b), c| {a, b, c} }
end

# Random tree where the parent of node `i` (> 0) is a node smaller than `i`.
private def random_parents(rng, n)
  Array.new(n) { |i| i == 0 ? -1 : rng.rand(i) }
end

private def naive_ancestors(parents, node)
  ancestors = [node]
  until parents[ancestors.last] == -1
    ancestors << parents[ancestors.last]
  end
  ancestors
end

private def naive_lca(parents, a, b)
  ancestors_b = naive_ancestors(parents, b)
  naive_ancestors(parents, a).find! { |node| ancestors_b.includes?(node) }
end

private def naive_dist(parents, a, b)
  lca = naive_lca(parents, a, b)
  naive_ancestors(parents, a).index!(lca) + naive_ancestors(parents, b).index!(lca)
end

describe "DirectedGraph" do
  describe "#add_edge" do
    it "returns sequential edge ids" do
      graph = DirectedGraph(Nil, Int64).new(3_i64)
      graph.add_edge(0, 1, 5_i64).should eq 0
      graph.add_edge(1, 2, 7_i64).should eq 1
    end
  end

  describe "#get_edge" do
    it "returns the edge info" do
      graph = DirectedGraph(Nil, Int64).new(3_i64)
      graph.add_edge(0, 1, 5_i64)
      graph.add_edge(1, 2)
      graph.get_edge(0, 1).should eq 5
      graph.get_edge(1, 2).should eq 1
    end

    it "does not return the edge in the reverse direction" do
      graph = DirectedGraph(Nil, Int64).new(2_i64)
      graph.add_edge(0, 1, 5_i64)
      expect_raises(KeyError) { graph.get_edge(1, 0) }
    end
  end

  describe "#update_edge" do
    it "updates the edge info" do
      graph = DirectedGraph(Nil, Int64).new(2_i64)
      edge_id = graph.add_edge(0, 1, 5_i64)
      graph.update_edge(0, 1, 3_i64).should eq edge_id
      graph.get_edge(0, 1).should eq 3
    end
  end

  describe "#dijkstra" do
    it "calculates distances and previous nodes" do
      graph = DirectedGraph(Nil, Int64).new(5_i64)
      graph.add_edge(0, 1, 4_i64)
      graph.add_edge(0, 2, 1_i64)
      graph.add_edge(2, 1, 2_i64)
      graph.add_edge(1, 3, 5_i64)
      graph.add_edge(3, 0, 1_i64)
      graph.dijkstra(0).should eq [
        {dist: 0, prev: nil},
        {dist: 3, prev: 2},
        {dist: 1, prev: 0},
        {dist: 8, prev: 1},
        {dist: nil, prev: nil},
      ]
    end

    it "calculates distances from a middle node" do
      graph = DirectedGraph(Nil, Int64).new(3_i64)
      graph.add_edge(0, 1, 1_i64)
      graph.add_edge(1, 2, 1_i64)
      graph.dijkstra(1).map(&.[:dist]).should eq [nil, 0, 1]
    end

    it "matches a naive implementation on random small graphs" do
      rng = Random.new(36)
      300.times do
        n = rng.rand(1..8)
        edges = random_edges(rng, n, rng.rand(0..20), directed: true)
        start = rng.rand(n)

        graph = DirectedGraph(Nil, Int64).new(n.to_i64)
        edges.each { |(a, b, c)| graph.add_edge(a, b, c) }
        result = graph.dijkstra(start)

        result.map(&.[:dist]).should eq naive_distances(n, edges, start, directed: true)
        result.each_with_index do |node, i|
          prev = node[:prev]
          next if prev.nil?
          (result[prev][:dist].not_nil! + graph.get_edge(prev, i)).should eq node[:dist]
        end
      end
    end
  end

  describe "#dfs" do
    it "visits reachable nodes with the node info" do
      graph = DirectedGraph(String, Int64).new(["a", "b", "c", "d"])
      graph.add_edge(0, 1)
      graph.add_edge(1, 2)
      graph.add_edge(3, 0)

      visited = [] of {Int64, String?, Int64}
      graph.dfs(0_i64, 0_i64) do |node, depth, info, callback|
        visited << {node, info[:node_info], depth}
        callback.call(depth + 1)
      end
      visited.should eq [{0, "a", 0}, {1, "b", 1}, {2, "c", 2}]
    end
  end
end

describe "UndirectedGraph" do
  describe "#get_edge" do
    it "returns the edge info in both directions" do
      graph = UndirectedGraph(Nil, Int64).new(2_i64)
      graph.add_edge(0, 1, 5_i64)
      graph.get_edge(0, 1).should eq 5
      graph.get_edge(1, 0).should eq 5
    end
  end

  describe "#update_edge" do
    it "updates the edge info in both directions" do
      graph = UndirectedGraph(Nil, Int64).new(2_i64)
      graph.add_edge(0, 1, 5_i64)
      graph.update_edge(1, 0, 3_i64)
      graph.get_edge(0, 1).should eq 3
    end
  end

  describe "#dijkstra" do
    it "matches a naive implementation on random small graphs" do
      rng = Random.new(36)
      300.times do
        n = rng.rand(1..8)
        edges = random_edges(rng, n, rng.rand(0..20), directed: false)
        start = rng.rand(n)

        graph = UndirectedGraph(Nil, Int64).new(n.to_i64)
        edges.each { |(a, b, c)| graph.add_edge(a, b, c) }
        graph.dijkstra(start).map(&.[:dist]).should eq naive_distances(n, edges, start, directed: false)
      end
    end
  end

  describe "#dfs" do
    it "passes the parent and the edge to the block" do
      graph = UndirectedGraph(Nil, Int64).new(3_i64)
      graph.add_edge(0, 1, 5_i64)
      graph.add_edge(2, 1, 7_i64)

      visited = [] of {Int64, Int64, Int64?, Int64?}
      graph.dfs(1_i64, nil) do |node, _value, info, callback|
        visited << {node, info[:parent], info[:edge], info[:edge_info]}
        callback.call(nil)
      end
      visited.should eq [{1, -1, nil, nil}, {0, 1, 0, 5}, {2, 1, 1, 7}]
    end

    it "visits nodes in depth-first order" do
      #   0
      #  / \
      # 1   4
      # |\
      # 2 3
      graph = UndirectedGraph(Nil, Int64).new(5_i64)
      graph.add_edge(0, 1)
      graph.add_edge(1, 2)
      graph.add_edge(1, 3)
      graph.add_edge(0, 4)

      visited = [] of {Int64, Int64}
      graph.dfs(0_i64, 0_i64) do |node, depth, _info, callback|
        visited << {node, depth}
        callback.call(depth + 1)
      end
      visited.should eq [{0, 0}, {1, 1}, {2, 2}, {3, 2}, {4, 1}]
    end

    it "does not visit the children if the callback is not called" do
      graph = UndirectedGraph(Nil, Int64).new(4_i64)
      graph.add_edge(0, 1)
      graph.add_edge(1, 2)
      graph.add_edge(0, 3)

      visited = [] of Int64
      graph.dfs(0_i64, nil) do |node, _value, _info, callback|
        visited << node
        callback.call(nil) unless node == 1
      end
      visited.should eq [0, 1, 3]
    end

    it "visits each node once on a graph with cycles" do
      # 0 - 1
      # | \ |
      # 3 - 2
      graph = UndirectedGraph(Nil, Int64).new(4_i64)
      graph.add_edge(0, 1)
      graph.add_edge(1, 2)
      graph.add_edge(2, 3)
      graph.add_edge(3, 0)
      graph.add_edge(0, 2)

      visited = [] of {Int64, Int64}
      graph.dfs(0_i64, nil) do |node, _value, info, callback|
        visited << {node, info[:parent]}
        callback.call(nil)
      end
      visited.should eq [{0, -1}, {1, 0}, {2, 1}, {3, 2}]
    end
  end
end

describe "Tree" do
  describe "#diameter" do
    it "returns the diameter, its endpoints and parents toward the start node" do
      #   1     3
      # 0 - 1 - 2 - 3
      #     | 2
      #     4 - 5
      #       4
      tree = Tree(Nil, Int64).new(6_i64)
      tree.add_edge(0, 1, 1_i64)
      tree.add_edge(1, 2, 1_i64)
      tree.add_edge(2, 3, 3_i64)
      tree.add_edge(1, 4, 2_i64)
      tree.add_edge(4, 5, 4_i64)

      diameter, start_node, target_node, parents = tree.diameter
      diameter.should eq 10
      {start_node, target_node}.should eq({5, 3})
      parents.should eq [1, 4, 1, 2, 5, -1]
    end

    it "counts edges when edge weights are omitted" do
      tree = Tree(Nil, Int64).new(4_i64)
      tree.add_edge(0, 1)
      tree.add_edge(1, 2)
      tree.add_edge(1, 3)
      tree.diameter[0].should eq 2
    end

    it "returns the only node as both endpoints for a single-node tree" do
      Tree(Nil, Int64).new(1_i64).diameter.should eq({0, 0, 0, [-1]})
    end

    it "returns existing nodes as endpoints when all edge weights are zero" do
      tree = Tree(Nil, Int64).new(3_i64)
      tree.add_edge(0, 1, 0_i64)
      tree.add_edge(1, 2, 0_i64)
      tree.diameter.should eq({0, 0, 0, [-1, 0, 1]})
    end

    it "does not overflow the stack on a long path" do
      n = 1_000_000_i64
      tree = Tree(Nil, Int64).new(n)
      (n - 1).times { |i| tree.add_edge(i, i + 1, 1_i64) }
      diameter, start_node, target_node, parents = tree.diameter
      diameter.should eq n - 1
      {start_node, target_node}.should eq({n - 1, 0})
      parents[0].should eq 1
    end

    it "matches a naive implementation on random small trees" do
      rng = Random.new(36)
      300.times do
        n = rng.rand(2..10)
        edges = random_parents(rng, n).each_with_index.skip(1).map { |(p, i)| {i, p, rng.rand(1_i64..10_i64)} }.to_a

        tree = Tree(Nil, Int64).new(n.to_i64)
        edges.each { |(a, b, c)| tree.add_edge(a, b, c) }
        diameter, start_node, target_node, parents = tree.diameter

        expected = (0...n).max_of { |i| naive_distances(n, edges, i, directed: false).compact.max }
        diameter.should eq expected

        length = 0_i64
        node = target_node
        until node == start_node
          length += tree.get_edge(node, parents[node])
          node = parents[node]
        end
        length.should eq expected
      end
    end
  end

  describe "#lca" do
    it "returns the lowest common ancestor rooted at node 0" do
      #     0
      #    / \
      #   1   2
      #  / \   \
      # 3   4   5
      #     |
      #     6
      tree = Tree(Nil, Int64).new(7_i64)
      tree.add_edge(0, 1)
      tree.add_edge(0, 2)
      tree.add_edge(1, 3)
      tree.add_edge(1, 4)
      tree.add_edge(2, 5)
      tree.add_edge(4, 6)
      tree.lca(3, 6).should eq 1
      tree.lca(6, 3).should eq 1
      tree.lca(6, 5).should eq 0
      tree.lca(4, 6).should eq 4
      tree.lca(2, 2).should eq 2
      tree.lca(0, 6).should eq 0
    end

    it "handles a long path" do
      n = 1000_i64
      tree = Tree(Nil, Int64).new(n)
      (n - 1).times { |i| tree.add_edge(i, i + 1) }
      tree.lca(n - 1, 500).should eq 500
      tree.lca(999, 998).should eq 998
    end

    it "does not overflow the stack on a long path" do
      n = 1_000_000_i64
      tree = Tree(Nil, Int64).new(n)
      (n - 1).times { |i| tree.add_edge(i, i + 1) }
      tree.lca(n - 1, 500_000).should eq 500_000
      tree.dist(0, n - 1).should eq n - 1
    end

    it "matches a naive implementation on random small trees" do
      rng = Random.new(36)
      100.times do
        n = rng.rand(1..40)
        parents = random_parents(rng, n)
        tree = Tree(Nil, Int64).new(n.to_i64)
        (1...n).each { |i| tree.add_edge(i, parents[i]) }

        n.times do |a|
          n.times do |b|
            tree.lca(a, b).should eq naive_lca(parents, a, b)
          end
        end
      end
    end
  end

  describe "#dist" do
    it "returns the number of edges on the path, ignoring edge weights" do
      tree = Tree(Nil, Int64).new(4_i64)
      tree.add_edge(0, 1, 10_i64)
      tree.add_edge(1, 2, 10_i64)
      tree.add_edge(1, 3, 10_i64)
      tree.dist(2, 3).should eq 2
      tree.dist(0, 2).should eq 2
      tree.dist(3, 3).should eq 0
    end

    it "matches a naive implementation on random small trees" do
      rng = Random.new(36)
      100.times do
        n = rng.rand(1..30)
        parents = random_parents(rng, n)
        tree = Tree(Nil, Int64).new(n.to_i64)
        (1...n).each { |i| tree.add_edge(i, parents[i]) }

        n.times do |a|
          n.times do |b|
            tree.dist(a, b).should eq naive_dist(parents, a, b)
          end
        end
      end
    end
  end

  describe "#on_path?" do
    it "returns whether the node is on the path" do
      # 0 - 1 - 2
      #     |
      #     3
      tree = Tree(Nil, Int64).new(4_i64)
      tree.add_edge(0, 1)
      tree.add_edge(1, 2)
      tree.add_edge(1, 3)
      tree.on_path?(0, 2, 1).should be_true
      tree.on_path?(0, 2, 0).should be_true
      tree.on_path?(0, 2, 2).should be_true
      tree.on_path?(0, 2, 3).should be_false
      tree.on_path?(3, 3, 3).should be_true
      tree.on_path?(3, 3, 1).should be_false
    end
  end
end
