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

require "../src/max_flow.cr"
require "spec"

alias MaxFlow = AtCoder::MaxFlow

# Minimum s-t cut by enumerating every vertex subset, which equals the maximum flow.
private def naive_max_flow(n, edges, s, t)
  (0...(1 << n)).select { |mask| mask.bit(s) == 1 && mask.bit(t) == 0 }.min_of do |mask|
    edges.sum(0_i64) do |(from, to, cap)|
      mask.bit(from) == 1 && mask.bit(to) == 0 ? cap : 0_i64
    end
  end
end

describe "MaxFlow" do
  describe ".new" do
    it "stores the number of nodes" do
      MaxFlow.new(5).size.should eq 5
    end
  end

  describe "#flow" do
    it "calculates the README example" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 3)
      mf.add_edge(1, 2, 1)
      mf.add_edge(0, 2, 2)
      mf.flow(0, 2).should eq 3
    end

    it "returns an Int64" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 3)
      mf.flow(0, 1).should be_a Int64
    end

    it "returns zero when the target is unreachable" do
      mf = MaxFlow.new(4)
      mf.add_edge(0, 1, 10)
      mf.add_edge(2, 3, 10)
      mf.add_edge(3, 0, 10)
      mf.flow(0, 3).should eq 0
    end

    it "returns zero when there are no edges" do
      MaxFlow.new(2).flow(0, 1).should eq 0
    end

    it "returns zero when start and target are the same node" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 10)
      mf.flow(0, 0).should eq 0
    end

    it "raises IndexError when start or target is out of bounds" do
      mf = MaxFlow.new(3)
      expect_raises(IndexError) { mf.flow(-1, 2) }
      expect_raises(IndexError) { mf.flow(0, 3) }
    end

    it "does not use edges in the reverse direction" do
      mf = MaxFlow.new(2)
      mf.add_edge(1, 0, 10)
      mf.flow(0, 1).should eq 0
    end

    it "sums up parallel edges" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 3)
      mf.add_edge(0, 1, 4)
      mf.flow(0, 1).should eq 7
    end

    it "handles zero-capacity edges and self loops" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 0, 5)
      mf.add_edge(0, 1, 0)
      mf.add_edge(0, 2, 2)
      mf.add_edge(2, 2, 5)
      mf.add_edge(2, 1, 3)
      mf.flow(0, 1).should eq 2
    end

    it "cancels flow through reverse edges" do
      # The greedy path 0 -> 1 -> 2 -> 3 must be partly cancelled to reach the optimum.
      mf = MaxFlow.new(4)
      mf.add_edge(0, 1, 1)
      mf.add_edge(0, 2, 1)
      mf.add_edge(1, 2, 1)
      mf.add_edge(1, 3, 1)
      mf.add_edge(2, 3, 1)
      mf.flow(0, 3).should eq 2
    end

    it "calculates a bipartite matching" do
      # Left: 1, 2, 3 / Right: 4, 5, 6 / source: 0 / sink: 7
      mf = MaxFlow.new(8)
      [1, 2, 3].each { |l| mf.add_edge(0, l, 1) }
      [4, 5, 6].each { |r| mf.add_edge(r, 7, 1) }
      mf.add_edge(1, 4, 1)
      mf.add_edge(2, 4, 1)
      mf.add_edge(3, 4, 1)
      mf.add_edge(3, 5, 1)
      mf.flow(0, 7).should eq 2
    end

    it "accepts capacities beyond Int32" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 10_000_000_000_i64)
      mf.add_edge(1, 2, 20_000_000_000_i64)
      mf.flow(0, 2).should eq 10_000_000_000_i64
    end

    it "returns only the additional flow when called again" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 5)
      mf.add_edge(1, 2, 3)
      mf.flow(0, 2).should eq 3
      mf.flow(0, 2).should eq 0
      mf.add_edge(0, 2, 4)
      mf.flow(0, 2).should eq 4
    end

    it "handles a long path graph" do
      n = 1000
      mf = MaxFlow.new(n)
      (n - 1).times { |i| mf.add_edge(i, i + 1, n - i) }
      mf.flow(0, n - 1).should eq 2
    end

    it "does not overflow the stack on a very long augmenting path" do
      # https://github.com/hakatashi/ac-library.cr/issues/26
      n = 200_000
      mf = MaxFlow.new(n)
      (n - 1).times { |i| mf.add_edge(i, i + 1, 1) }
      mf.flow(0, n - 1).should eq 1
    end

    it "matches a naive minimum cut on random small graphs" do
      rng = Random.new(36)
      300.times do
        n = rng.rand(2..6)
        edges = Array.new(rng.rand(0..12)) do
          {rng.rand(n), rng.rand(n), rng.rand(0_i64..10_i64)}
        end
        s = rng.rand(n)
        t = (s + rng.rand(1...n)) % n

        mf = MaxFlow.new(n)
        edges.each { |(from, to, cap)| mf.add_edge(from, to, cap) }
        mf.flow(s, t).should eq naive_max_flow(n, edges, s, t)
      end
    end
  end

  describe "#min_cut" do
    it "calculates the README example" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 3)
      mf.add_edge(1, 2, 1)
      mf.add_edge(0, 2, 2)
      mf.flow(0, 2).should eq 3
      mf.min_cut(0).should eq [true, true, false]
    end

    it "returns an Array(Bool)" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 3)
      mf.flow(0, 1)
      mf.min_cut(0).should be_a Array(Bool)
    end

    it "returns only the start node when there are no edges" do
      mf = MaxFlow.new(3)
      mf.min_cut(1).should eq [false, true, false]
    end

    it "handles a single-node graph with self-loops" do
      mf = MaxFlow.new(1)
      mf.add_edge(0, 0, 5)
      mf.add_edge(0, 0, 3)
      mf.min_cut(0).should eq [true]
    end

    it "ignores zero-capacity edges and reaches nodes before flow is called" do
      mf = MaxFlow.new(4)
      mf.add_edge(0, 1, 2)
      mf.add_edge(1, 2, 0)
      mf.add_edge(2, 3, 5)
      mf.min_cut(0).should eq [true, true, false, false]
    end

    it "traverses reverse residual edges created by pushed flow" do
      mf = MaxFlow.new(4)
      mf.add_edge(0, 1, 1)
      mf.add_edge(1, 2, 1)
      mf.add_edge(2, 3, 1)
      mf.flow(0, 3).should eq 1
      mf.min_cut(0).should eq [true, false, false, false]

      mf.add_edge(0, 2, 1)
      mf.flow(0, 3).should eq 0
      mf.min_cut(0).should eq [true, true, true, false]
    end

    it "accepts Int64 start and supports repeated calls from different starts" do
      mf = MaxFlow.new(4)
      mf.add_edge(0, 1, 1)
      mf.add_edge(2, 3, 1)
      mf.flow(0, 1).should eq 1
      mf.min_cut(0_i64).should eq [true, false, false, false]
      mf.min_cut(2_i64).should eq [false, false, true, true]
      mf.min_cut(3_i64).should eq [false, false, false, true]
    end

    it "raises IndexError when start is out of bounds" do
      mf = MaxFlow.new(3)
      expect_raises(IndexError) { mf.min_cut(-1) }
      expect_raises(IndexError) { mf.min_cut(3) }

      empty_mf = MaxFlow.new(0)
      expect_raises(IndexError) { empty_mf.min_cut(0) }
    end

    it "does not overflow the stack on a very long graph" do
      n = 200_000
      mf = MaxFlow.new(n)
      (n - 1).times do |i|
        cap = i == 100_000 ? 1_i64 : 2_i64
        mf.add_edge(i, i + 1, cap)
      end
      mf.flow(0, n - 1).should eq 1

      cut = mf.min_cut(0)
      cut.size.should eq n
      cut[0..100_000].all?.should be_true
      cut[100_001..].none?.should be_true
    end

    it "matches naive residual reachability and minimum cut capacity on random small graphs" do
      rng = Random.new(42)
      300.times do
        n = rng.rand(2..6)
        edges = Array.new(rng.rand(0..12)) do
          {rng.rand(n), rng.rand(n), rng.rand(0_i64..10_i64)}
        end
        s = rng.rand(n)
        t = (s + rng.rand(1...n)) % n

        mf = MaxFlow.new(n)
        edges.each { |(from, to, cap)| mf.add_edge(from, to, cap) }
        max_flow = mf.flow(s, t)
        cut = mf.min_cut(s)

        cut.size.should eq n
        cut[s].should be_true
        cut[t].should be_false

        cut_cap = edges.sum(0_i64) do |(from, to, cap)|
          cut[from] && !cut[to] ? cap : 0_i64
        end
        cut_cap.should eq max_flow
        cut_cap.should eq naive_max_flow(n, edges, s, t)

        # Independently verify exact reachability in the residual graph via relaxation.
        expected = Array.new(n, false)
        expected[s] = true
        n.times do
          n.times do |u|
            next unless expected[u]
            mf.adjacencies[u].each do |edge|
              expected[edge.to] = true if edge.capacity > 0
            end
          end
        end
        cut.should eq expected
      end
    end
  end

  describe "#add_edge" do
    it "returns the index of the added edge" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 3).should eq 0
      mf.add_edge(1, 2, 1).should eq 1
      mf.add_edge(0, 0, 5).should eq 2
      mf.add_edge(0, 1, 3).should be_a Int64
    end

    it "raises IndexError when a node is out of bounds" do
      mf = MaxFlow.new(3)
      expect_raises(IndexError) { mf.add_edge(-1, 2, 1) }
      expect_raises(IndexError) { mf.add_edge(0, 3, 1) }
    end

    it "raises ArgumentError when the capacity is negative" do
      expect_raises(ArgumentError) { MaxFlow.new(2).add_edge(0, 1, -1) }
    end
  end

  describe "#get_edge" do
    it "returns the original capacity and the flow" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 3)
      mf.add_edge(1, 2, 1)
      mf.add_edge(0, 2, 2)
      mf.get_edge(0).should eq MaxFlow::EdgeInfo.new(0, 1, 3, 0)
      mf.flow(0, 2).should eq 3
      mf.get_edge(0).should eq MaxFlow::EdgeInfo.new(0, 1, 3, 1)
      mf.get_edge(1).should eq MaxFlow::EdgeInfo.new(1, 2, 1, 1)
      mf.get_edge(2).should eq MaxFlow::EdgeInfo.new(0, 2, 2, 2)
    end

    it "supports field access" do
      mf = MaxFlow.new(2)
      mf.add_edge(1, 0, 7)
      edge = mf.get_edge(0)
      {edge.from, edge.to, edge.cap, edge.flow}.should eq({1, 0, 7, 0})
    end

    it "distinguishes parallel edges, opposite edges and self-loops" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 2)
      mf.add_edge(0, 1, 3)
      mf.add_edge(1, 0, 4)
      mf.add_edge(1, 1, 5)
      mf.add_edge(1, 2, 4)
      mf.flow(0, 2).should eq 4
      mf.get_edge(0).flow.should eq 2
      mf.get_edge(1).flow.should eq 2
      mf.get_edge(2).should eq MaxFlow::EdgeInfo.new(1, 0, 4, 0)
      mf.get_edge(3).should eq MaxFlow::EdgeInfo.new(1, 1, 5, 0)
      mf.get_edge(4).flow.should eq 4
    end

    it "raises IndexError when the index is out of bounds" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 1)
      expect_raises(IndexError) { mf.get_edge(-1) }
      expect_raises(IndexError) { mf.get_edge(1) }
    end
  end

  describe "#edges" do
    it "returns all edges in order of addition" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 3)
      mf.add_edge(1, 2, 1)
      mf.add_edge(0, 2, 2)
      mf.flow(0, 2)
      mf.edges.should eq [
        MaxFlow::EdgeInfo.new(0, 1, 3, 1),
        MaxFlow::EdgeInfo.new(1, 2, 1, 1),
        MaxFlow::EdgeInfo.new(0, 2, 2, 2),
      ]
    end

    it "returns an empty array when there are no edges" do
      MaxFlow.new(2).edges.should be_empty
    end

    it "satisfies flow conservation on random graphs" do
      rng = Random.new(32)
      200.times do
        n = rng.rand(2..8)
        mf = MaxFlow.new(n)
        caps = Array.new(rng.rand(0..20)) do
          {rng.rand(n), rng.rand(n), rng.rand(0_i64..10_i64)}
        end
        caps.each { |(from, to, cap)| mf.add_edge(from, to, cap) }
        s = rng.rand(n)
        t = (s + rng.rand(1...n)) % n
        total = mf.flow(s, t)

        edges = mf.edges
        edges.size.should eq caps.size
        net = Array.new(n, 0_i64)
        edges.each_with_index do |edge, i|
          {edge.from, edge.to, edge.cap}.should eq caps[i]
          (0 <= edge.flow <= edge.cap).should be_true
          net[edge.from] += edge.flow
          net[edge.to] -= edge.flow
        end
        n.times do |v|
          expected = v == s ? total : (v == t ? -total : 0_i64)
          net[v].should eq expected
        end
      end
    end
  end

  describe "#change_edge" do
    it "changes the capacity and the flow of an edge" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 3)
      mf.change_edge(0, 5, 2)
      mf.get_edge(0).should eq MaxFlow::EdgeInfo.new(0, 1, 5, 2)
      mf.flow(0, 1).should eq 3
      mf.get_edge(0).should eq MaxFlow::EdgeInfo.new(0, 1, 5, 5)
    end

    it "matches ACL's documented behavior of rerunning flow" do
      mf = MaxFlow.new(3)
      mf.add_edge(0, 1, 1)
      mf.add_edge(1, 2, 1)
      mf.flow(0, 2).should eq 1
      mf.change_edge(0, 2, 0)
      mf.change_edge(1, 2, 0)
      mf.flow(0, 2).should eq 2
    end

    it "returns nil" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 1)
      mf.change_edge(0, 1, 1).should be_nil
    end

    it "works on self-loops" do
      mf = MaxFlow.new(1)
      mf.add_edge(0, 0, 3)
      mf.change_edge(0, 4, 1)
      mf.get_edge(0).should eq MaxFlow::EdgeInfo.new(0, 0, 4, 1)
    end

    it "raises ArgumentError unless 0 <= flow <= capacity" do
      mf = MaxFlow.new(2)
      mf.add_edge(0, 1, 3)
      expect_raises(ArgumentError) { mf.change_edge(0, 3, 4) }
      expect_raises(ArgumentError) { mf.change_edge(0, 3, -1) }
      expect_raises(ArgumentError) { mf.change_edge(0, -1, 0) }
      mf.get_edge(0).should eq MaxFlow::EdgeInfo.new(0, 1, 3, 0)
    end

    it "raises IndexError when the index is out of bounds" do
      mf = MaxFlow.new(2)
      expect_raises(IndexError) { mf.change_edge(0, 1, 0) }
    end
  end
end
