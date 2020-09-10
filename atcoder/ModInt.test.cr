require "./ModInt.cr"
require "spec"

include AtCoder

describe "ModInt100000007" do
  describe "#==" do
    it "has a sound equality" do
      ModInt100000007.new(100_i64).should eq 100
      ModInt100000007.new(100_i64).should eq 100_i64
      ModInt100000007.new(100_i64).should_not eq 101
      ModInt100000007.new(100_i64).should_not eq 101_i64
      ModInt100000007.new(100_i64).should eq ModInt100000007.new(100_i64)
      ModInt100000007.new(100_i64).should_not eq ModInt100000007.new(101_i64)
      (ModInt100000007.new(100_i64) == 100).should eq true
      (ModInt100000007.new(100_i64) == 101).should eq false
      (ModInt100000007.new(100_i64) != 100).should eq false
      (ModInt100000007.new(100_i64) != 101).should eq true
    end
  end

  describe ".new" do
    it "constructs ModInt100000007 from Int64" do
      n = ModInt100000007.new(100_i64)
      n.should eq 100
    end
  end

  describe "#inv" do
    it "generates inverse number under modulo" do
      n = ModInt100000007.new(1_i64)
      n.inv.should eq n

      n = ModInt100000007.new(100_i64)
      n.inv.should eq 570000004

      n = ModInt100000007.new(-1_i64 % 1_000_000_007_i64)
      n.inv.should eq n
    end

    it "generates inverse number that multiplies with self into one" do
      1_i64.step(by: 17, to: 1000) do |i|
        (ModInt100000007.new(i).inv * i).should eq 1
      end
    end
  end

  describe "#+" do
    it "adds with number" do
      n = ModInt100000007.new(1_i64)
      (n + 100).should eq 101
      (n + 1_000_000_007_i64).should eq 1
    end
  end

  describe "#-" do
    it "subtracts with number" do
      n = ModInt100000007.new(100_i64)
      (n - 10).should eq 90
      (n - 1000).should eq -900 % 1_000_000_007_i64
    end
  end

  describe "#*" do
    it "multiplies with number" do
      n = ModInt100000007.new(100_i64)
      (n * 334).should eq 33400
      (n * -42).should eq -4200 % 1_000_000_007_i64
      (n * 10_000_000_000_i64).should eq -7000 % 1_000_000_007_i64
    end
  end

  describe "#/" do
    it "divides with number" do
      n = ModInt100000007.new(700_i64)
      (n // 5).should eq 140
      (n // -1).should eq -700 % 1_000_000_007_i64
      (n // 10_000_000_000_i64).should eq -10 % 1_000_000_007_i64
    end

    it "generates number that multiplies with self into the original one" do
      1_i64.step(by: 9_837, to: 100_000) do |i|
        1_000_000_i64.step(by: 9_837, to: 100_000) do |j|
          (ModInt100000007.new(i) // j * j).should eq i
        end
      end
    end
  end

  describe "#**" do
    it "generates powered number" do
      n = ModInt100000007.new(5_i64)
      (n ** 0).should eq 1
      (n ** 5).should eq 3125
      (n ** -3).should eq ModInt100000007.new(1_i64) // 125
      (n ** 100_000).should eq 754_573_817
    end
  end

  describe "#sqrt" do
    it "generates square-rooted number" do
      ModInt100000007.new(100_i64).sqrt.should eq 10
      ModInt100000007.new(2_i64).sqrt.should eq 59_713_600
      ModInt100000007.new(5_i64).sqrt.should eq nil
    end
  end

  describe "#to_s" do
    it "serializes value as number" do
      ModInt100000007.new(100_i64).to_s.should eq "100"
      ModInt100000007.new(123_456_789_i64).to_s.should eq "123456789"
    end
  end

  describe "#inspect" do
    it "serializes value as number" do
      ModInt100000007.new(100_i64).inspect.should eq "100"
      ModInt100000007.new(123_456_789_i64).inspect.should eq "123456789"
    end
  end

  describe ".factorial" do
    it "calculates factorial fast" do
      ModInt100000007.factorial(3_i64).should eq 6
      ModInt100000007.factorial(10_i64).should eq 3628800
    end
  end

  describe ".permutation" do
    it "calculates permutation fast" do
      ModInt100000007.permutation(4_i64, 2_i64).should eq 12
      ModInt100000007.permutation(10_i64, 3_i64).should eq 720
    end
  end

  describe ".combination" do
    it "calculates combination fast" do
      ModInt100000007.combination(4_i64, 2_i64).should eq 6
      ModInt100000007.combination(10_i64, 3_i64).should eq 120
    end
  end

  describe "Int" do
    describe "#+" do
      it "calculates addition with ModInt100000007" do
        (100 + ModInt100000007.new(10_i64)).should eq 110
      end
    end

    describe "#-" do
      it "calculates substriction with ModInt100000007" do
        (100 - ModInt100000007.new(10_i64)).should eq 90
      end
    end

    describe "#*" do
      it "calculates multiplication with ModInt100000007" do
        (100 * ModInt100000007.new(10_i64)).should eq 1000
      end
    end

    describe "#//" do
      it "calculates multiplication with ModInt100000007" do
        (100 // ModInt100000007.new(10_i64)).should eq 10
      end
    end

    describe "#==" do
      it "determines identity with ModInt100000007" do
        (100 == ModInt100000007.new(100_i64)).should eq true
      end
    end
  end
end