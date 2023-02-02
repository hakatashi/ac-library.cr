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

require "../src/string_algorithm.cr"
require "spec"

describe "StringAlgorithm" do
  describe ".suffix_array" do
    it "returns suffix array in O(n)" do
      AtCoder::StringAlgorithm.suffix_array("abcbcba").should eq [6, 0, 5, 3, 1, 4, 2]
      AtCoder::StringAlgorithm.suffix_array("mississippi").should eq [10, 7, 4, 1, 0, 9, 8, 6, 3, 5, 2]
      AtCoder::StringAlgorithm.suffix_array("ababacaca").should eq [8, 0, 2, 6, 4, 1, 3, 7, 5]
      AtCoder::StringAlgorithm.suffix_array("aaaaa").should eq [4, 3, 2, 1, 0]
    end

    it "returns suffix array in O(n log(n))" do
      AtCoder::StringAlgorithm.suffix_array([1_i64, 2_i64, 3_i64, 2_i64, 3_i64, 2_i64, 1_i64]).should eq [6, 0, 5, 3, 1, 4, 2]
      AtCoder::StringAlgorithm.suffix_array([2**12, 2**8, 2**18, 2**18, 2**8, 2**18, 2**18, 2**8, 2**15, 2**15, 2**8]).should eq [10, 7, 4, 1, 0, 9, 8, 6, 3, 5, 2]
      AtCoder::StringAlgorithm.suffix_array([1, 2, 1, 2, 1, 3, 1, 3, 1]).should eq [8, 0, 2, 6, 4, 1, 3, 7, 5]
      AtCoder::StringAlgorithm.suffix_array([10_i64**18, 10_i64**18, 10_i64**18, 10_i64**18, 10_i64**18]).should eq [4, 3, 2, 1, 0]
    end

    it "returns suffix array in O(n + uppper)" do
      AtCoder::StringAlgorithm.suffix_array([1, 2, 3, 2, 3, 2, 1], 3).should eq [6, 0, 5, 3, 1, 4, 2]
      AtCoder::StringAlgorithm.suffix_array([2**12, 2**8, 2**18, 2**18, 2**8, 2**18, 2**18, 2**8, 2**15, 2**15, 2**8], 2**18).should eq [10, 7, 4, 1, 0, 9, 8, 6, 3, 5, 2]
      AtCoder::StringAlgorithm.suffix_array([1, 2, 1, 2, 1, 3, 1, 3, 1], 3).should eq [8, 0, 2, 6, 4, 1, 3, 7, 5]
      AtCoder::StringAlgorithm.suffix_array([0, 0, 0, 0, 0], 10**8).should eq [4, 3, 2, 1, 0]
    end
  end

  describe ".z_algorithm" do
    it "returns empty array if input sequence is empty" do
      AtCoder::StringAlgorithm.z_algorithm([] of Int32).should eq [] of Int32
      AtCoder::StringAlgorithm.z_algorithm("").should eq [] of Int32
    end

    it "returns the sequence of length n, such that the i-th element is the length of the LCP (Longest Common Prefix) of s[0...n] and s[i...n]." do
      AtCoder::StringAlgorithm.z_algorithm("abcbcba").should eq [7, 0, 0, 0, 0, 0, 1]
      AtCoder::StringAlgorithm.z_algorithm("mississippi").should eq [11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      AtCoder::StringAlgorithm.z_algorithm("ababacaca").should eq [9, 0, 3, 0, 1, 0, 1, 0, 1]
      AtCoder::StringAlgorithm.z_algorithm("aaaaa").should eq [5, 4, 3, 2, 1]

      AtCoder::StringAlgorithm.z_algorithm([1, 2, 3, 2, 3, 2, 1]).should eq [7, 0, 0, 0, 0, 0, 1]
      AtCoder::StringAlgorithm.z_algorithm([1, 2, 3, 3, 2, 3, 3, 2, 4, 4, 2]).should eq [11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      AtCoder::StringAlgorithm.z_algorithm([1, 2, 1, 2, 1, 3, 1, 3, 1]).should eq [9, 0, 3, 0, 1, 0, 1, 0, 1]
      AtCoder::StringAlgorithm.z_algorithm([1, 1, 1, 1, 1]).should eq [5, 4, 3, 2, 1]
    end
  end
end
