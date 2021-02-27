# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
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

require "../../atcoder/FenwickTree.cr"
require "../../atcoder/ModInt.cr"
require "../spec_helper.cr"
require "spec"

alias FenwickTree = AtCoder::FenwickTree

describe "FenwickTree" do
  describe "#left_sum" do
    it "calculates left_sum of given list" do
      tree = FenwickTree(Int64).new(11_i64)
      11_i64.times do |i|
        tree.add(i, i)
      end

      tree.left_sum(0).should eq 0
      tree.left_sum(1).should eq 0
      tree.left_sum(2).should eq 1
      tree.left_sum(3).should eq 3
      tree.left_sum(4).should eq 6
      tree.left_sum(5).should eq 10
      tree.left_sum(6).should eq 15
      tree.left_sum(7).should eq 21
      tree.left_sum(8).should eq 28
      tree.left_sum(9).should eq 36
      tree.left_sum(10).should eq 45
      tree.left_sum(11).should eq 55
    end
  end

  describe "#[]" do
    it "calculates range sum of given list" do
      tree = FenwickTree(Int64).new(11_i64)
      11_i64.times do |i|
        tree.add(i, i)
      end

      tree[2..4].should eq 9
      tree[0..10].should eq 55
      tree[0...3].should eq 3
      tree[3...7].should eq 18
      tree[0...11].should eq 55
      tree[7...7].should eq 0
    end
  end

  it "can be used with ModInt" do
    tree = FenwickTree(ModInt7).new(11_i64)
    11_i64.times do |i|
      tree.add(i, i)
    end

    tree[4..4].should eq 4
    tree[10..10].should eq 3
    tree[4...7].should eq 1
    tree[0...11].should eq 6
  end
end
