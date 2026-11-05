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

require "../src/scc.cr"
require "spec"

alias SCC = AtCoder::SCC

# Strongly connected components by the transitive closure (Warshall–Floyd).
private def naive_scc(n, edges)
  reach = Array.new(n) { |i| Array.new(n) { |j| i == j } }
  edges.each { |(from, to)| reach[from][to] = true }
  n.times do |k|
    n.times do |i|
      n.times do |j|
        reach[i][j] ||= reach[i][k] && reach[k][j]
      end
    end
  end
  Set.new(Array.new(n) { |i| (0_i64...n.to_i64).select { |j| reach[i][j] && reach[j][i] }.to_set })
end

# Checks that `groups` is in topological order: every edge goes to the same or a later group.
private def topologically_sorted?(groups, edges)
  index = {} of Int64 => Int32
  groups.each_with_index { |group, i| group.each { |v| index[v] = i } }
  edges.all? { |(from, to)| index[from.to_i64] <= index[to.to_i64] }
end

describe "SCC" do
  describe "#scc" do
    it "calculates the README example" do
      scc = SCC.new(3_i64)
      scc.add_edge(0, 1)
      scc.add_edge(1, 0)
      scc.add_edge(2, 0)
      scc.scc.should eq [Set{2}, Set{0, 1}]
    end

    it "returns an empty array for an empty graph" do
      SCC.new(0_i64).scc.should eq [] of Set(Int64)
    end

    it "returns singletons for a graph without edges" do
      SCC.new(3_i64).scc.to_set.should eq Set{Set{0}, Set{1}, Set{2}}
    end

    it "returns groups in topological order for a path" do
      scc = SCC.new(4_i64)
      scc.add_edge(2, 3)
      scc.add_edge(0, 1)
      scc.add_edge(1, 2)
      scc.scc.should eq [Set{0}, Set{1}, Set{2}, Set{3}]
    end

    it "merges a cycle into one group" do
      scc = SCC.new(4_i64)
      scc.add_edge(0, 1)
      scc.add_edge(1, 2)
      scc.add_edge(2, 3)
      scc.add_edge(3, 0)
      scc.scc.should eq [Set{0, 1, 2, 3}]
    end

    it "handles self loops and multiple edges" do
      scc = SCC.new(2_i64)
      scc.add_edge(0, 0)
      scc.add_edge(0, 1)
      scc.add_edge(0, 1)
      scc.scc.should eq [Set{0}, Set{1}]
    end

    it "returns the same result when called twice" do
      scc = SCC.new(3_i64)
      scc.add_edge(0, 1)
      scc.add_edge(1, 0)
      scc.add_edge(2, 0)
      scc.scc
      scc.scc.should eq [Set{2}, Set{0, 1}]
    end

    it "reflects edges added after the previous call" do
      scc = SCC.new(2_i64)
      scc.add_edge(0, 1)
      scc.scc.should eq [Set{0}, Set{1}]
      scc.add_edge(1, 0)
      scc.scc.should eq [Set{0, 1}]
    end

    it "handles a long path without stack overflow" do
      n = 1_000_000_i64
      scc = SCC.new(n)
      (n - 1).times { |i| scc.add_edge(i, i + 1) }
      groups = scc.scc
      groups.size.should eq n
      groups.first.should eq Set{0}
      groups.last.should eq Set{n - 1}
    end

    it "matches a naive implementation on random small graphs" do
      rng = Random.new(36)
      300.times do
        n = rng.rand(1..8)
        edges = Array.new(rng.rand(0..16)) { {rng.rand(n), rng.rand(n)} }

        scc = SCC.new(n.to_i64)
        edges.each { |(from, to)| scc.add_edge(from, to) }
        groups = scc.scc

        groups.to_set.should eq naive_scc(n, edges)
        topologically_sorted?(groups, edges).should be_true
      end
    end
  end

  describe "#add_edge" do
    it "raises IndexError for an out-of-range vertex" do
      scc = SCC.new(2_i64)
      expect_raises(IndexError) { scc.add_edge(0, 2) }
      expect_raises(IndexError) { scc.add_edge(-1, 0) }
    end
  end

  describe "#adjacencies" do
    it "returns in/out adjacency lists" do
      scc = SCC.new(3_i64)
      scc.add_edge(0, 1)
      scc.add_edge(2, 1)
      scc.add_edge(0, 2)
      scc.adjacencies.should eq [
        {in: [] of Int64, out: [1_i64, 2_i64]},
        {in: [0_i64, 2_i64], out: [] of Int64},
        {in: [0_i64], out: [1_i64]},
      ]
    end
  end
end
