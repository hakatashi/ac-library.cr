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

  describe "unimplemented methods" do
    it "raises NotImplementedError" do
      mf = MaxFlow.new(2)
      expect_raises(NotImplementedError) { mf.min_cut }
      expect_raises(NotImplementedError) { mf.get_edge }
      expect_raises(NotImplementedError) { mf.edges }
      expect_raises(NotImplementedError) { mf.change_edge }
    end
  end
end
