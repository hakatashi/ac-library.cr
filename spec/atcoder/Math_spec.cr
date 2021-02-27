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

require "../../atcoder/Math.cr"
require "../spec_helper.cr"
require "spec"

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
      expect_raises(ArgumentError) {AtCoder::Math.inv_mod(3, 9)}
      expect_raises(ArgumentError) {AtCoder::Math.inv_mod(0, 1000)}
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
      AtCoder::Math.pow_mod(100, 0, 1000).should eq 1
      AtCoder::Math.pow_mod(0, -10, 1000).should eq 0
      AtCoder::Math.pow_mod(123_456_789_i64, 1_000_000_006_i64, 1_000_000_007_i64).should eq 1
    end

    it "raises error when there's no inverse" do
      expect_raises(ArgumentError) {AtCoder::Math.pow_mod(3, -2, 9)}
      expect_raises(ArgumentError) {AtCoder::Math.pow_mod(100, -10, 1000)}
    end
  end
end
