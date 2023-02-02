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

require "../src/prime.cr"
require "spec"

alias Prime = AtCoder::Prime

describe "Prime" do
  it "generates valid array of primes from the beginning" do
    # https://oeis.org/A000040
    expected = [
      2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59,
      61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131,
      137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197,
      199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271,
    ]

    Prime.first(58).should eq expected
  end

  describe ".prime_division" do
    it "should factorize given number" do
      Prime.prime_division(1).should eq [] of Int64
      Prime.prime_division(175_i16).should eq [{5, 2}, {7, 1}]
      Prime.prime_division(4096).should eq [{2, 12}]
      Prime.prime_division(59049).should eq [{3, 10}]
      Prime.prime_division(9_219_364_293_862_490_881_i64).should eq [{55103, 4}]
      Prime.prime_division(4_611_686_018_427_387_904_i64).should eq [{2, 62}]
      Prime.prime_division(1_000_000_000_000_000_000_i64).should eq [{2, 18}, {5, 18}]
      Prime.prime_division(-1_000_000_i64).should eq [{-1, 1}, {2, 6}, {5, 6}]
      Prime.prime_division(1_231_230_i64).should eq [{2, 1}, {3, 1}, {5, 1}, {7, 1}, {11, 1}, {13, 1}, {41, 1}]
      Prime.prime_division(4_295_098_369_i64).should eq [{65537, 2}]
    end
  end

  describe ".int_from_prime_division" do
    it "should calculate weighted product of given base factors" do
      Prime.int_from_prime_division([{2, 6}, {5, 6}]).should eq 1_000_000
      Prime.int_from_prime_division([{2, 1}, {3, 1}, {5, 1}, {7, 1}, {11, 1}, {13, 1}, {41, 1}]).should eq 1_231_230
      Prime.int_from_prime_division([{2_i64, 32_i64}]).should eq 4_294_967_296_i64
      Prime.int_from_prime_division([{65521_u64, 4_u64}]).should eq 18_429_861_372_428_076_481_u64
    end
  end

  describe ".prime?" do
    it "is consistent with the result of prime generation" do
      primes_under1000 = Prime.take_while { |prime| prime < 1000 }.to_set
      0_i64.upto(1000_i64) do |n|
        Prime.prime?(n).should eq primes_under1000.includes?(n)
      end
    end

    it "can determine the primirity of large numbers" do
      # https://en.wikipedia.org/wiki/Repunit#Factorization_of_decimal_repunits
      Prime.prime?(1_i64).should be_false
      Prime.prime?(11_i64).should be_true
      Prime.prime?(111_i64).should be_false
      Prime.prime?(1_111_i64).should be_false
      Prime.prime?(11_111_i64).should be_false
      Prime.prime?(111_111_i64).should be_false
      Prime.prime?(1_111_111_i64).should be_false
      Prime.prime?(11_111_111_i64).should be_false
      Prime.prime?(111_111_111_i64).should be_false
      Prime.prime?(1_111_111_111_i64).should be_false
      Prime.prime?(11_111_111_111_i64).should be_false
      Prime.prime?(111_111_111_111_i64).should be_false
      Prime.prime?(1_111_111_111_111_i64).should be_false
      Prime.prime?(11_111_111_111_111_i64).should be_false
      Prime.prime?(111_111_111_111_111_i64).should be_false
      Prime.prime?(1_111_111_111_111_111_i64).should be_false
      Prime.prime?(11_111_111_111_111_111_i64).should be_false
      Prime.prime?(111_111_111_111_111_111_i64).should be_false
      Prime.prime?(1_111_111_111_111_111_111_i64).should be_true

      # https://oeis.org/A123568
      Prime.prime?(31_i64).should be_true
      Prime.prime?(331_i64).should be_true
      Prime.prime?(3_331_i64).should be_true
      Prime.prime?(33_331_i64).should be_true
      Prime.prime?(333_331_i64).should be_true
      Prime.prime?(3_333_331_i64).should be_true
      Prime.prime?(33_333_331_i64).should be_true
      Prime.prime?(333_333_331_i64).should be_false
      Prime.prime?(3_333_333_331_i64).should be_false
      Prime.prime?(33_333_333_331_i64).should be_false
      Prime.prime?(333_333_333_331_i64).should be_false
      Prime.prime?(3_333_333_333_331_i64).should be_false
      Prime.prime?(33_333_333_333_331_i64).should be_false
      Prime.prime?(333_333_333_333_331_i64).should be_false
      Prime.prime?(3_333_333_333_333_331_i64).should be_false
      Prime.prime?(33_333_333_333_333_331_i64).should be_false
      Prime.prime?(333_333_333_333_333_331_i64).should be_true
      Prime.prime?(3_333_333_333_333_333_331_i64).should be_false

      # https://en.wikipedia.org/wiki/Truncatable_prime#Decimal_truncatable_primes
      Prime.prime?(7_i64).should be_true
      Prime.prime?(37_i64).should be_true
      Prime.prime?(137_i64).should be_true
      Prime.prime?(9_137_i64).should be_true
      Prime.prime?(29_137_i64).should be_true
      Prime.prime?(629_137_i64).should be_true
      Prime.prime?(7_629_137_i64).should be_true
      Prime.prime?(67_629_137_i64).should be_true
      Prime.prime?(567_629_137_i64).should be_true
      Prime.prime?(6_567_629_137_i64).should be_true
      Prime.prime?(16_567_629_137_i64).should be_true
      Prime.prime?(216_567_629_137_i64).should be_true
      Prime.prime?(6_216_567_629_137_i64).should be_true
      Prime.prime?(46_216_567_629_137_i64).should be_true
      Prime.prime?(646_216_567_629_137_i64).should be_true
      Prime.prime?(2_646_216_567_629_137_i64).should be_true
      Prime.prime?(12_646_216_567_629_137_i64).should be_true
      Prime.prime?(312_646_216_567_629_137_i64).should be_true
    end
  end

  describe ".each_divisor" do
    it "should iterate through all positive divisor of given number" do
      Prime.each_divisor(1).to_set.should eq Set{1}
      Prime.each_divisor(100_i8).to_set.should eq Set{1, 2, 4, 5, 10, 20, 25, 50, 100}
      Prime.each_divisor(4_295_098_369_i64).to_set.should eq Set{1, 65537, 4_295_098_369}
      Prime.each_divisor(321_593_407_609_i64).to_set.should eq Set{1, 41, 7843741649, 321593407609}
    end

    it "raises if the argument is non-positive" do
      expect_raises(ArgumentError) { Prime.each_divisor(0) }
      expect_raises(ArgumentError) { Prime.each_divisor(-100_i64) }
    end
  end
end
