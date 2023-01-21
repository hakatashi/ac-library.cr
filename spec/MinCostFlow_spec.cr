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
    it "is sound" do
      flow = MinCostFlow.new(5)
      flow.add_edge(0, 1, 30_i64, 3_i64)
      flow.add_edge(0, 2, 60_i64, 9_i64)
      flow.add_edge(1, 2, 40_i64, 5_i64)
      flow.add_edge(1, 3, 50_i64, 7_i64)
      flow.add_edge(2, 3, 20_i64, 8_i64)
      flow.add_edge(2, 4, 50_i64, 6_i64)
      flow.add_edge(3, 4, 60_i64, 7_i64)
      flow.flow(0, 4, 70_i64).should eq 1080
    end
  end
end

