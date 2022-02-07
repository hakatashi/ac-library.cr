# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2022 Google LLC
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

require "../src/SegTree.cr"
require "../src/ModInt.cr"
require "./spec_helper.cr"
require "spec"

alias SegTree = AtCoder::SegTree

describe "SegTree" do
  describe "with default comparison" do
    describe "#[]" do
      it "simply returns value of tree" do
        segtree = SegTree.new((1..100).to_a)
        segtree[0].should eq 1
        segtree[10].should eq 11
        segtree[19].should eq 20
        segtree[50].should eq 51
        segtree[99].should eq 100
      end

      it "takes maximum value of selected range" do
        segtree = SegTree.new((1..100).to_a)
        segtree[0...100].should eq 100
        segtree[10...50].should eq 50
        segtree[50...70].should eq 70
        segtree[12...33].should eq 33

        segtree[0..0].should eq 1
        segtree[16..16].should eq 17
        segtree[49..49].should eq 50
        segtree[88..88].should eq 89
      end
    end

    describe "#[]=" do
      it "updates value at selected index" do
        segtree = SegTree.new((1..100).to_a)
        segtree[40] = 9999
        segtree[40].should eq 9999
        segtree[0...100].should eq 9999

        segtree[99] = 99999
        segtree[99].should eq 99999
        segtree[0...100].should eq 99999
      end
    end
  end

  describe "with custom comparison block" do
    describe "min comparison" do
      it "takes maximum value of selected range" do
        segtree = SegTree.new((1..100).to_a) {|a, b| [a, b].min}
        segtree[0...100].should eq 1
        segtree[10...50].should eq 11
        segtree[50...70].should eq 51
        segtree[12...33].should eq 13

        segtree[0..0].should eq 1
        segtree[16..16].should eq 17
        segtree[49..49].should eq 50
        segtree[88..88].should eq 89
      end
    end
  end

  it "can be used with ModInt" do
    values = 100.times.map {|i| Mint.new(1_i64) << i}.to_a
    segtree = SegTree.new(values) {|a, b| a + b}
    segtree[0...32].should eq 0xFFFFFFFF % Mint::MOD
  end
end
