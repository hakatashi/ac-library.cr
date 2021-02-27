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
    end

    it "raises error when there's no inverse" do
      expect_raises(ArgumentError) {AtCoder::Math.inv_mod(3, 9)}
    end
  end

  describe ".pow_mod" do
    it "generates powered number" do
      AtCoder::Math.pow_mod(10, 3, 29).should eq 14
    end
  end
end
