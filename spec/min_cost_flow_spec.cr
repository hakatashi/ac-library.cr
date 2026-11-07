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

require "../src/min_cost_flow.cr"
require "spec"

alias MinCostFlow = AtCoder::MinCostFlow

# Naive successive shortest path with Bellman-Ford on an edge list
private def naive_min_cost_flow(n, edges, start, target, flow_limit)
  to = [] of Int64
  cap = [] of Int64
  cost = [] of Int64
  from = [] of Int64
  edges.each do |(u, v, c, d)|
    from << u; to << v; cap << c; cost << d
    from << v; to << u; cap << 0_i64; cost << -d
  end

  flow = 0_i64
  total = 0_i64
  while flow < flow_limit
    dist = Array(Int64 | Nil).new(n, nil)
    prev = Array(Int64).new(n, -1_i64)
    dist[start] = 0_i64
    n.times do
      from.size.times do |i|
        du = dist[from[i]]
        next if du.nil? || cap[i] == 0
        dv = dist[to[i]]
        if dv.nil? || dv > du + cost[i]
          dist[to[i]] = du + cost[i]
          prev[to[i]] = i.to_i64
        end
      end
    end
    target_dist = dist[target]
    break if target_dist.nil?

    c = flow_limit - flow
    v = target
    until v == start
      c = Math.min(c, cap[prev[v]])
      v = from[prev[v]]
    end
    v = target
    until v == start
      cap[prev[v]] -= c
      cap[prev[v] ^ 1] += c
      v = from[prev[v]]
    end
    flow += c
    total += c * target_dist
  end
  {flow, total}
end

describe "MinCostFlow" do
  describe ".flow" do
    it "raises ArgumentError when start and target is the same" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 1, 30, 3)
      expect_raises(ArgumentError) { flow.flow(0, 0, 20) }
    end

    it "returns zero when there's no capacity anymore" do
      flow = MinCostFlow.new(2)
      flow.add_edge(1, 0, 30, 3)
      flow.flow(0, 1, 0).should eq({0, 0})
    end

    it "calculates min-cost flow from start to target" do
      flow = MinCostFlow.new(5)
      flow.add_edge(0, 1, 30, 3)
      flow.add_edge(0, 2, 60, 9)
      flow.add_edge(1, 2, 40, 5)
      flow.add_edge(1, 3, 50, 7)
      flow.add_edge(2, 3, 20, 8)
      flow.add_edge(2, 4, 50, 6)
      flow.add_edge(3, 4, 60, 7)
      flow.flow(0, 4, 70).should eq({70, 1080})
    end

    it "returns correct capacity and cost when there's multiple routes with the same costs" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 1)
      flow.add_edge(1, 2, 10, 1)
      flow.add_edge(0, 2, 10, 2)
      flow.flow(0, 2, 20).should eq({20, 40})
    end

    it "returns slope to the maximum capacity if the third argument is omitted" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 2)
      flow.add_edge(1, 2, 10, 1)
      flow.add_edge(0, 2, 10, 2)
      flow.flow(0, 2).should eq({20, 50})
    end

    it "returns slope to the maximum capacity if the capacity is full" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 2)
      flow.add_edge(1, 2, 10, 1)
      flow.add_edge(0, 2, 10, 2)
      flow.flow(0, 2, 30).should eq({20, 50})
    end

    it "returns zero when the graph is not connected" do
      flow = MinCostFlow.new(4)
      flow.add_edge(0, 1, 30, 3)
      flow.add_edge(2, 3, 30, 3)
      flow.flow(0, 3, 10).should eq({0, 0})
    end

    it "handles parallel edges" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 1, 1, 1)
      flow.add_edge(0, 1, 1, 5)
      flow.flow(0, 1).should eq({2, 6})
    end

    it "handles edges in the opposite direction of existing edges" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 2, 1)
      flow.add_edge(1, 0, 1, 1)
      flow.add_edge(1, 2, 2, 1)
      flow.flow(0, 2).should eq({2, 4})
    end

    it "handles self-loops" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 0, 10, 1)
      flow.add_edge(0, 1, 3, 2)
      flow.add_edge(1, 1, 10, 0)
      flow.flow(0, 1).should eq({3, 6})
    end

    it "continues from the previous result when called multiple times" do
      flow = MinCostFlow.new(4)
      flow.add_edge(0, 1, 2, 1)
      flow.add_edge(0, 2, 2, 3)
      flow.add_edge(1, 3, 1, 1)
      flow.add_edge(2, 3, 3, 1)
      flow.add_edge(1, 2, 2, 0)
      flow.flow(0, 3, 1).should eq({1, 2})
      flow.flow(0, 3, 2).should eq({2, 6})
      flow.flow(0, 3).should eq({1, 4})
      flow.flow(0, 3).should eq({0, 0})
    end

    it "matches a naive implementation on random graphs" do
      rng = Random.new(42)
      300.times do
        n = rng.rand(2_i64..6_i64)
        m = rng.rand(0..12)
        edges = Array.new(m) do
          {rng.rand(0_i64...n), rng.rand(0_i64...n), rng.rand(0_i64..5_i64), rng.rand(0_i64..5_i64)}
        end
        start = rng.rand(0_i64...n)
        target = (start + rng.rand(1_i64...n)) % n
        flow_limit = rng.rand(0_i64..20_i64)

        flow = MinCostFlow.new(n)
        edges.each { |(u, v, c, d)| flow.add_edge(u, v, c, d) }
        flow.flow(start, target, flow_limit).should eq naive_min_cost_flow(n, edges, start, target, flow_limit)
      end
    end
  end

  describe ".add_edge" do
    it "returns the index of the added edge" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 1, 1).should eq 0
      flow.add_edge(1, 2, 1, 1).should eq 1
      flow.add_edge(0, 1, 1, 1).should eq 2
    end
  end

  describe ".slope" do
    it "raises ArgumentError when start and target is the same" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 1, 30, 3)
      expect_raises(ArgumentError) { flow.slope(0, 0, 20) }
    end

    it "returns single point when there's no capacity anymore" do
      flow = MinCostFlow.new(2)
      flow.add_edge(1, 0, 30, 3)
      flow.slope(0, 1, 0).should eq [
        {0, 0},
      ]
    end

    it "calculates min-cost slope from start to target" do
      flow = MinCostFlow.new(5)
      flow.add_edge(0, 1, 30, 3)
      flow.add_edge(0, 2, 60, 9)
      flow.add_edge(1, 2, 40, 5)
      flow.add_edge(1, 3, 50, 7)
      flow.add_edge(2, 3, 20, 8)
      flow.add_edge(2, 4, 50, 6)
      flow.add_edge(3, 4, 60, 7)
      flow.slope(0, 4, 70).should eq [
        {0, 0},
        {30, 420},
        {50, 720},
        {70, 1080},
      ]
    end

    it "returns line with slope with gradient zero if initial flow cost is zero" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 0)
      flow.add_edge(1, 2, 10, 0)
      flow.add_edge(0, 2, 10, 1)
      flow.slope(0, 2, 15).should eq [
        {0, 0},
        {10, 0},
        {15, 5},
      ]
    end

    it "returns single line when there's multiple routes with the same costs" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 1)
      flow.add_edge(1, 2, 10, 1)
      flow.add_edge(0, 2, 10, 2)
      flow.slope(0, 2, 20).should eq [
        {0, 0},
        {20, 40},
      ]
    end

    it "returns slope to the maximum capacity if the third argument is omitted" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 2)
      flow.add_edge(1, 2, 10, 1)
      flow.add_edge(0, 2, 10, 2)
      flow.slope(0, 2).should eq [
        {0, 0},
        {10, 20},
        {20, 50},
      ]
    end

    it "returns slope to the maximum capacity if the capacity is full" do
      flow = MinCostFlow.new(3)
      flow.add_edge(0, 1, 10, 2)
      flow.add_edge(1, 2, 10, 1)
      flow.add_edge(0, 2, 10, 2)
      flow.slope(0, 2, 30).should eq [
        {0, 0},
        {10, 20},
        {20, 50},
      ]
    end
  end

  describe "unimplemented methods" do
    it "raises NotImplementedError" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 1, 1, 1)
      expect_raises(NotImplementedError) { flow.get_edge(0) }
      expect_raises(NotImplementedError) { flow.edges }
    end
  end
end
