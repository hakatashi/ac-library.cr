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

require "../src/LazySegTree.cr"
require "../src/ModInt.cr"
require "./spec_helper.cr"
require "spec"

alias LazySegTree = AtCoder::LazySegTree

describe "LazySegTree" do
  describe "#[]" do
    it "simply returns value of tree" do
      op = ->(a : Int32, b : Int32) { a + b }
      mapping = ->(f : Int32, x : Int32) { x * f }
      composition = ->(a : Int32, b : Int32) { a * b }
      segtree = LazySegTree(Int32, Int32).new((1..100).to_a, op, mapping, composition)

      segtree[0].should eq 1
      segtree[10].should eq 11
      segtree[19].should eq 20
      segtree[50].should eq 51
      segtree[99].should eq 100
    end

    it "takes sum of selected range" do
      op = ->(a : Int32, b : Int32) { a + b }
      mapping = ->(f : Int32, x : Int32) { x * f }
      composition = ->(a : Int32, b : Int32) { a * b }
      segtree = LazySegTree(Int32, Int32).new((1..100).to_a, op, mapping, composition)

      segtree[0...100].should eq 5050
      segtree[10...50].should eq 1220
      segtree[50...70].should eq 1210
      segtree[12...33].should eq 483

      segtree[0..0].should eq 1
      segtree[16..16].should eq 17
      segtree[49..49].should eq 50
      segtree[88..88].should eq 89
    end
  end

  describe "#[]=" do
    it "updates value at selected index" do
      op = ->(a : Int32, b : Int32) { a + b }
      mapping = ->(f : Int32, x : Int32) { x * f }
      composition = ->(a : Int32, b : Int32) { a * b }
      segtree = LazySegTree(Int32, Int32).new((1..100).to_a, op, mapping, composition)

      segtree[40] = 9999
      segtree[40].should eq 41 * 9999
      segtree[0...100].should eq 5050 + 41 * 9998

      segtree[99] = 99999
      segtree[99].should eq 9999900
      segtree[0...100].should eq 5050 + 41 * 9998 - 100 + 9999900
    end

    it "bulk-updates values" do
      op = ->(a : Int32, b : Int32) { a + b }
      mapping = ->(f : Int32, x : Int32) { x * f }
      composition = ->(a : Int32, b : Int32) { a * b }
      segtree = LazySegTree(Int32, Int32).new((1..100).to_a, op, mapping, composition)

      segtree[10...30] = 2
      segtree[9].should eq 10
      segtree[10].should eq 22
      segtree[19].should eq 40
      segtree[29].should eq 60
      segtree[30].should eq 31
      segtree[49].should eq 50
      segtree[99].should eq 100
      segtree[0...100].should eq 5050 + 410

      segtree[29...40] = 5
      segtree[28].should eq 58
      segtree[29].should eq 300
      segtree[30].should eq 155
      segtree[39].should eq 200
      segtree[40].should eq 41
      segtree[41].should eq 42
      segtree[0...100].should eq 5050 + 410 + 240 + 355 * 4
    end
  end

  it "can be used with ModInt" do
    op = ->(a : Mint, b : Mint) { a + b }
    mapping = ->(f : Int64, x : Mint) { x * f }
    composition = ->(a : Int64, b : Int64) { a * b }
    values = 100.times.map {|i| Mint.new(1_i64) << i}.to_a
    segtree = LazySegTree(Mint, Int64).new(values, op, mapping, composition)

    segtree[0...32].should eq 0xFFFFFFFF % Mint::MOD
    segtree[0...100] = 8
    segtree[0...100] = 32
    segtree[8...40].should eq 0xFFFFFFFF0000 % Mint::MOD
  end
end
