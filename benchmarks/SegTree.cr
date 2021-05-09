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

require "../atcoder/SegTree.cr"
require "spec"

include AtCoder

describe "SegTree" do
  describe "bench" do
    # O(nlogn)
    it "should finish" do
      n = 1000000
      segtree = SegTree.new((1..n).to_a)
      n.times do |i|
        segtree[0..i].should eq i + 1
      end
    end
  end
end
