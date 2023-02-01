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

require "../src/math.cr"
require "./spec_helper.cr"
require "spec"

def floor_sum_naive(n, m, a, b)
  sum = 0i64
  n.times do |i|
    z = a * i + b
    sum += (z - z % m) // m
  end
  sum
end

describe "Math" do
  describe ".inv_mod" do
    it "generates inverse number under modulo" do
      AtCoder::Math.inv_mod(1, 9).should eq 1
      AtCoder::Math.inv_mod(8, 13).should eq 5
      AtCoder::Math.inv_mod(3, 299).should eq 100
      AtCoder::Math.inv_mod(-1, 7).should eq 6
      AtCoder::Math.inv_mod(1_000_000_007_i64, 1_000_000_000_000_000_000_i64).should eq 551_020_408_142_857_143_i64
    end

    it "raises error when there's no inverse" do
      expect_raises(ArgumentError) { AtCoder::Math.inv_mod(3, 9) }
      expect_raises(ArgumentError) { AtCoder::Math.inv_mod(0, 1000) }
    end
  end

  describe ".pow_mod" do
    it "generates powered number" do
      AtCoder::Math.pow_mod(10, 3, 29).should eq 14
      AtCoder::Math.pow_mod(123_456, 0, 1_000_003).should eq 1
      AtCoder::Math.pow_mod(100, 100, 299).should eq 100
      AtCoder::Math.pow_mod(3, -100, 299).should eq 100
      AtCoder::Math.pow_mod(0, 0, 1000).should eq 1
      AtCoder::Math.pow_mod(100, 10, 1000).should eq 0
      AtCoder::Math.pow_mod(10, 2, 1000).should eq 100
      AtCoder::Math.pow_mod(100, 0, 1000).should eq 1
      AtCoder::Math.pow_mod(0, -10, 1000).should eq 0
      AtCoder::Math.pow_mod(123_456_789_i64, 1_000_000_006_i64, 1_000_000_007_i64).should eq 1
    end

    it "raises error when there's no inverse" do
      expect_raises(ArgumentError) { AtCoder::Math.pow_mod(3, -2, 9) }
      expect_raises(ArgumentError) { AtCoder::Math.pow_mod(100, -10, 1000) }
    end
  end

  describe ".crt" do
    it "calculates chinese remainder theorem answers" do
      AtCoder::Math.crt([5, 7], [10, 11]).should eq({95, 110})
      AtCoder::Math.crt([73, 10073], [10000, 20000]).should eq({10073, 20000})
      AtCoder::Math.crt([2, 3, 2], [3, 5, 7]).should eq({23, 105})
      AtCoder::Math.crt([10, 15, 10], [15, 25, 35]).should eq({115, 525})
      AtCoder::Math.crt([11, 16, 11], [15, 25, 35]).should eq({116, 525})
    end

    it "returns {0, 1} if the given array is empty" do
      AtCoder::Math.crt([] of Int32, [] of Int32).should eq({0, 1})
    end

    it "returns {0, 0} if there's no such answer" do
      AtCoder::Math.crt([1, 2], [10, 15]).should eq({0, 0})
      AtCoder::Math.crt([109, 185], [213, 267]).should eq({0, 0})
    end

    it "raises error when sizes of given arrays don't match" do
      expect_raises(ArgumentError) { AtCoder::Math.crt([] of Int32, [1]) }
      expect_raises(ArgumentError) { AtCoder::Math.crt([1, 2, 3], [4, 5]) }
    end
  end

  describe ".floor_sum" do
    it "calculates floor_sum" do
      # https://atcoder.jp/contests/practice2/tasks/practice2_c
      AtCoder::Math.floor_sum(4, 10, 6, 3).should eq 3
      AtCoder::Math.floor_sum(6, 5, 4, 3).should eq 13
      AtCoder::Math.floor_sum(1, 1, 0, 0).should eq 0
      AtCoder::Math.floor_sum(31415, 92653, 58979, 32384).should eq 314_095_480
      AtCoder::Math.floor_sum(1_000_000_000, 1_000_000_000, 999_999_999, 999_999_999).should eq 499_999_999_500_000_000
    end

    it "equals floor_sum_naive" do
      (0...20).each do |n|
        (1...20).each do |m|
          (-20...20).each do |a|
            (-20...20).each do |b|
              AtCoder::Math.floor_sum(n, m, a, b).should eq floor_sum_naive(n, m, a, b)
            end
          end
        end
      end
    end
  end

  describe ".product_greater_than" do
    it "checks if the product of a and b is greater than target" do
      AtCoder::Math.product_greater_than(4, 3, 13).should eq false
      AtCoder::Math.product_greater_than(4, 3, 12).should eq false
      AtCoder::Math.product_greater_than(4, 3, 11).should eq true
      AtCoder::Math.product_greater_than(4, 3, 10).should eq true

      AtCoder::Math.product_greater_than(3, 4, 13).should eq false
      AtCoder::Math.product_greater_than(3, 4, 12).should eq false
      AtCoder::Math.product_greater_than(3, 4, 11).should eq true
      AtCoder::Math.product_greater_than(3, 4, 10).should eq true
    end
  end
end
