# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2022 Google LLC
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

require "../src/DSU.cr"
require "benchmark"
require "spec"

Benchmark.bm do |x|
  # O(nlogn)
  x.report("AtCoder::DSU") do
    n = 1000000_i64

    tree = AtCoder::DSU.new((n + 1) * 3)
    (0...n).to_a.shuffle.each do |i|
      tree.merge(i * 3, (i + 1) * 3)
      tree.merge(i * 3 + 1, (i + 1) * 3 + 1)
      tree.merge(i * 3 + 2, (i + 1) * 3 + 2)
    end

    tree.size(n * 3).should eq n + 1
    tree.size(n * 3 + 1).should eq n + 1
    tree.size(n * 3 + 2).should eq n + 1

    n.times do |i|
      tree.same(0, i * 3 + 1).should eq false
      tree.same(1, i * 3 + 2).should eq false
      tree.same(2, i * 3 + 2).should eq true
    end

    tree.merge(0, 1)
    tree.merge(1, 2)

    tree.size(n // 2).should eq (n + 1) * 3
  end
end
