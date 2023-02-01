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

require "../src/string.cr"
require "spec"

describe "String" do
  describe ".z_algorithm" do
    it "return empty array if input sequence is empty" do
      AtCoder::String.z_algorithm([] of Int32).should eq [] of Int32
      AtCoder::String.z_algorithm("").should eq [] of Int32
    end

    it "returns the sequence of length n, such that the i-th element is the length of the LCP (Longest Common Prefix) of s[0...n] and s[i...n]." do
      AtCoder::String.z_algorithm("abcbcba").should eq [7, 0, 0, 0, 0, 0, 1]
      AtCoder::String.z_algorithm("mississippi").should eq [11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      AtCoder::String.z_algorithm("ababacaca").should eq [9, 0, 3, 0, 1, 0, 1, 0, 1]
      AtCoder::String.z_algorithm("aaaaa").should eq [5, 4, 3, 2, 1]

      AtCoder::String.z_algorithm([1, 2, 3, 2, 3, 2, 1]).should eq [7, 0, 0, 0, 0, 0, 1]
      AtCoder::String.z_algorithm([1, 2, 3, 3, 2, 3, 3, 2, 4, 4, 2]).should eq [11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      AtCoder::String.z_algorithm([1, 2, 1, 2, 1, 3, 1, 3, 1]).should eq [9, 0, 3, 0, 1, 0, 1, 0, 1]
      AtCoder::String.z_algorithm([1, 1, 1, 1, 1]).should eq [5, 4, 3, 2, 1]
    end
  end
end
