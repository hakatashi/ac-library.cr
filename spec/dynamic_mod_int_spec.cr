# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
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

require "../src/mod_int.cr"
require "spec"

alias DynamicModInt = AtCoder::DynamicModInt

describe "DynamicModInt" do
  describe ".mod" do
    it "defaults to 998244353" do
      DynamicModInt.mod.should eq 998_244_353
      DynamicModInt.new(998_244_354).should eq 1
    end
  end

  describe ".set_mod" do
    it "changes the modulus" do
      DynamicModInt.set_mod(101)
      DynamicModInt.mod.should eq 101
      (DynamicModInt.new(80) + DynamicModInt.new(90)).should eq 69
      DynamicModInt.set_mod(7)
      DynamicModInt.mod.should eq 7
      (DynamicModInt.new(3) * 5).should eq 1
    end

    it "raises ArgumentError for invalid modulus" do
      expect_raises(ArgumentError) { DynamicModInt.set_mod(0) }
      expect_raises(ArgumentError) { DynamicModInt.set_mod(-5) }
      expect_raises(ArgumentError) { DynamicModInt.set_mod(Int32::MAX.to_i64 + 1) }
    end

    it "clears the cache of factorials" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.factorial(20).should eq 146_326_063
      DynamicModInt.set_mod(13)
      DynamicModInt.factorial(5).should eq 120 % 13
      DynamicModInt.factorial(20).should eq 0
    end
  end

  describe ".new" do
    it "takes the modulo of any integer" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.new.should eq 0
      DynamicModInt.new(1_000_000_008).should eq 1
      DynamicModInt.new(-1).should eq 1_000_000_006
      DynamicModInt.new(Int64::MAX).should eq 291_172_003
      DynamicModInt.new(Int64::MIN).should eq 708_828_003
      DynamicModInt.new(UInt64::MAX).should eq UInt64::MAX % 1_000_000_007
      DynamicModInt.new(-3_i8).should eq 1_000_000_004
      DynamicModInt.new(Int128::MAX).should eq Int128::MAX % 1_000_000_007
    end
  end

  describe ".raw" do
    it "constructs without taking the modulo" do
      DynamicModInt.set_mod(101)
      DynamicModInt.raw(100).should eq 100
    end
  end

  describe "arithmetic" do
    it "matches a naive implementation" do
      [1_i64, 2_i64, 3_i64, 4_i64, 998_244_353_i64, 1_000_000_007_i64, 2_147_483_646_i64, Int32::MAX.to_i64].each do |m|
        DynamicModInt.set_mod(m)
        values = [0_i64, 1_i64, 2_i64, m - 1, m - 2, m // 2, m // 3 + 1, 12_345_678_i64 % m, 2_147_483_000_i64 % m].map(&.clamp(0_i64, m - 1))
        values.each do |a|
          values.each do |b|
            x, y = DynamicModInt.new(a), DynamicModInt.new(b)
            (x + y).should eq (a + b) % m
            (x - y).should eq (a - b) % m
            (x * y).should eq (a.to_i128 * b % m).to_i64
            (x * b).should eq (a.to_i128 * b % m).to_i64
            (a * y).should eq (a.to_i128 * b % m).to_i64
            (-x).should eq (-a) % m
          end
        end
      end
    end

    it "matches a naive implementation for random values" do
      rng = Random.new(42)
      200.times do
        m = rng.rand(1_i64..Int32::MAX.to_i64)
        DynamicModInt.set_mod(m)
        20.times do
          a = rng.rand(0_i64...m)
          b = rng.rand(0_i64...m)
          (DynamicModInt.new(a) * DynamicModInt.new(b)).should eq (a.to_i128 * b % m).to_i64
        end
      end
    end
  end

  describe "#inv" do
    it "generates inverse number under a prime modulus" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.new(100).inv.should eq 570_000_004
      1_i64.step(by: 17, to: 1000) do |i|
        (DynamicModInt.new(i).inv * i).should eq 1
      end
    end

    it "works under a composite modulus for coprime values" do
      DynamicModInt.set_mod(12)
      DynamicModInt.new(5).inv.should eq 5
      DynamicModInt.new(7).inv.should eq 7
      (DynamicModInt.new(1) / 11).should eq 11
    end

    it "raises ArgumentError for non-coprime values" do
      DynamicModInt.set_mod(12)
      expect_raises(ArgumentError) { DynamicModInt.new(4).inv }
    end
  end

  describe "#/" do
    it "divides with number" do
      DynamicModInt.set_mod(1_000_000_007)
      n = DynamicModInt.new(700)
      (n // 5).should eq 140
      (n / DynamicModInt.new(7)).should eq 100
      (n // -1).should eq -700 % 1_000_000_007
      (700 // DynamicModInt.new(7)).should eq 100
    end

    it "throws DivisionByZeroError when it tried to divide by zero" do
      DynamicModInt.set_mod(1_000_000_007)
      expect_raises(DivisionByZeroError) { DynamicModInt.new(700) // 0 }
      expect_raises(DivisionByZeroError) { DynamicModInt.new(700) / DynamicModInt.new(0) }
    end
  end

  describe "#**" do
    it "generates powered number" do
      DynamicModInt.set_mod(1_000_000_007)
      n = DynamicModInt.new(5)
      (n ** 0).should eq 1
      (n ** 5).should eq 3125
      n.pow(5).should eq 3125
      (n ** -3).should eq DynamicModInt.new(1) // 125
      (n ** 100_000).should eq 754_573_817
      (DynamicModInt.new(0) ** 5).should eq 0
    end

    it "matches Math.pow_mod" do
      [2_i64, 9_i64, 1_000_000_i64, 998_244_353_i64, Int32::MAX.to_i64].each do |m|
        DynamicModInt.set_mod(m)
        [0_i64, 1_i64, 2_i64, 31_i64, 1_000_000_000_000_i64].each do |e|
          (DynamicModInt.new(3) ** e).should eq AtCoder::Math.pow_mod(3_i64 % m, e, m) % m
        end
      end
    end

    it "returns 0 for any power under modulus 1" do
      DynamicModInt.set_mod(1)
      (DynamicModInt.new(5) ** 0).should eq 0
      (DynamicModInt.new(5) ** 3).should eq 0
    end
  end

  describe "#sqrt" do
    it "generates square-rooted number" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.new(100).sqrt.should eq 10
      DynamicModInt.new(2).sqrt.should eq 59_713_600
      DynamicModInt.new(5).sqrt.should eq nil
    end
  end

  describe "#to_s / #inspect / #val" do
    it "serializes value as number" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.new(123_456_789).to_s.should eq "123456789"
      DynamicModInt.new(123_456_789).inspect.should eq "123456789"
      DynamicModInt.new(123_456_789).val.should eq 123_456_789
      [DynamicModInt.new(1), DynamicModInt.new(2)].to_s.should eq "[1, 2]"
    end
  end

  describe "comparison" do
    it "raises NotImplementedError" do
      expect_raises(NotImplementedError) { DynamicModInt.new(1) < DynamicModInt.new(2) }
    end
  end

  describe ".combination" do
    it "calculates combination under the current modulus" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.permutation(10, 3).should eq 720
      DynamicModInt.combination(10, 3).should eq 120
      DynamicModInt.set_mod(7)
      DynamicModInt.combination(6, 3).should eq 20 % 7
    end

    it "returns 0 when k < 0 or k > n" do
      DynamicModInt.set_mod(1_000_000_007)
      DynamicModInt.combination(3, 4).should eq 0
      DynamicModInt.combination(3, -1).should eq 0
      DynamicModInt.permutation(3, 4).should eq 0
      DynamicModInt.repeated_combination(0, 0).should eq 1
      DynamicModInt.repeated_combination(0, 2).should eq 0
      expect_raises(ArgumentError) { DynamicModInt.combination(-1, 0) }
    end
  end

  describe "Int" do
    it "calculates with DynamicModInt" do
      DynamicModInt.set_mod(1_000_000_007)
      (100 + DynamicModInt.new(10)).should eq 110
      (100 - DynamicModInt.new(10)).should eq 90
      (100 * DynamicModInt.new(10)).should eq 1000
      (100 // DynamicModInt.new(10)).should eq 10
      (100 == DynamicModInt.new(100)).should eq true
    end
  end
end
