# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
#
# Copyright 2020 Google LLC
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

require "./UnionFindTree.cr"
require "spec"

describe "UnionFindTree" do
  describe "#unite" do
    it "unifies group of trees into unions" do
      tree = UnionFindTree.new(9)

      tree.unite(0, 2)
      tree.unite(2, 4)
      tree.unite(4, 6)

      tree.unite(7, 1)
      tree.unite(7, 3)
      tree.unite(7, 5)

      tree.same(2, 6).should eq true
      tree.same(4, 2).should eq true
      tree.same(1, 3).should eq true
      tree.same(3, 5).should eq true
      tree.same(8, 8).should eq true
      tree.same(2, 1).should eq false
      tree.same(7, 0).should eq false
      tree.same(5, 4).should eq false
      tree.same(8, 7).should eq false

      tree.size(4).should eq 4
      tree.size(1).should eq 4
      tree.size(8).should eq 1
    end
  end
end