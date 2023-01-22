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

require "../src/MinCostFlow.cr"
require "spec"

alias MinCostFlow = AtCoder::MinCostFlow

describe "MinCostFlow" do
  describe ".flow" do
    it "raises ArgumentError when start and target is the same" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 1, 30, 3)
      expect_raises(ArgumentError) {flow.flow(0, 0, 20)}
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
  end

  describe ".slope" do
    it "raises ArgumentError when start and target is the same" do
      flow = MinCostFlow.new(2)
      flow.add_edge(0, 1, 30, 3)
      expect_raises(ArgumentError) {flow.slope(0, 0, 20)}
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
end

