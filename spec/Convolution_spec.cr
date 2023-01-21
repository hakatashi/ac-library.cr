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

require "../src/Convolution.cr"
require "../src/ModInt.cr"
require "spec"

alias Convolution = AtCoder::Convolution
alias Mint9 = AtCoder::ModInt998244353

describe "Convolution" do
  describe ".convolution" do
    it "return empty array if any of input array is empty" do
      Convolution.convolution([] of Mint9, [] of Mint9).should eq [] of Mint9
      Convolution.convolution([Mint9.new(1_i64)], [] of Mint9).should eq [] of Mint9
      Convolution.convolution([] of Mint9, [Mint9.new(1_i64)]).should eq [] of Mint9
    end

    it "calculates convolution of input arrays" do
      a = [AtCoder::ModInt998244353.new(1_i64)] * 3
      Convolution.convolution(a, a).should eq [1, 2, 3, 2, 1]
    end
  end

  describe ".convolution_ll" do
    it "calculates convolution of input arrays" do
      a = [1_i64] * 3
      Convolution.convolution_ll(a, a).should eq [1, 2, 3, 2, 1]
    end

    it "can calculate convolutions up to Int64 max" do
      a = [1_000_000_000_i64] * 9
      Convolution.convolution_ll(a, a).should eq [
        1_000_000_000_000_000_000_i64,
        2_000_000_000_000_000_000_i64,
        3_000_000_000_000_000_000_i64,
        4_000_000_000_000_000_000_i64,
        5_000_000_000_000_000_000_i64,
        6_000_000_000_000_000_000_i64,
        7_000_000_000_000_000_000_i64,
        8_000_000_000_000_000_000_i64,
        9_000_000_000_000_000_000_i64,
        8_000_000_000_000_000_000_i64,
        7_000_000_000_000_000_000_i64,
        6_000_000_000_000_000_000_i64,
        5_000_000_000_000_000_000_i64,
        4_000_000_000_000_000_000_i64,
        3_000_000_000_000_000_000_i64,
        2_000_000_000_000_000_000_i64,
        1_000_000_000_000_000_000_i64,
      ]
    end
  end
end
