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

require "../src/RedBlackTree.cr"
require "spec"

alias RedBlackTree = AtCoder::RedBlackTree

describe "RedBlackTree" do
  it "pops values in priority order" do
    tree = RedBlackTree.new
    tree << 5
    tree << 6
    tree << 1
    tree << 3
    tree << 2
    tree << 8
    tree << 7
    tree << 4
    tree.max.should eq 8
    tree.min.should eq 1

    tree.delete 1
    tree.delete 5
    tree.delete 8

    tree.max.should eq 7
    tree.min.should eq 2
  end

  it "implements enumerable" do
    tree = RedBlackTree.new
    tree << 5
    tree << 6
    tree << 1
    tree << 3
    tree << 2
    tree << 8
    tree << 7
    tree << 4
    tree.first(5).should eq [1, 2, 3, 4, 5]
  end

  describe "#empty?" do
    it "should report true if queue is empty" do
      tree = RedBlackTree.new
      tree.empty?.should eq true
      tree << 1
      tree.empty?.should eq false
      tree.delete 1
      tree.empty?.should eq true
    end
  end
end
