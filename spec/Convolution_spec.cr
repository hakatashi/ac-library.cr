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
alias Mint = AtCoder::ModInt998244353

describe "Convolution" do
  describe ".convolution" do
    it "is sound" do
      Convolution.convolution([
        Mint.new(100_i64),
        Mint.new(101_i64),
        Mint.new(103_i64),
        Mint.new(105_i64),
      ], [
        Mint.new(100_i64),
        Mint.new(200_i64),
        Mint.new(400_i64),
        Mint.new(900_i64),
        Mint.new(1100_i64),
      ]).should eq [10000, 30100, 70500, 161500, 263100, 245800, 207800, 115500]
    end
  end
end

