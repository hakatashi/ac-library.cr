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

require "../src/max_flow.cr"
require "benchmark"
require "spec"

Benchmark.bm do |x|
  x.report("AtCoder::MaxFlow (bipartite matching)") do
    l = 10_000_i64
    r = 10_000_i64
    mf = AtCoder::MaxFlow.new(l + r + 2)
    s = 0_i64
    t = l + r + 1_i64

    l.times { |i| mf.add_edge(s, i + 1, 1) }
    r.times { |i| mf.add_edge(l + i + 1, t, 1) }

    # Augmented cycle pattern: alternating cycle with chords
    l.times do |i|
      mf.add_edge(i + 1, l + i + 1, 1)
      mf.add_edge(i + 1, l + ((i + 1) % r) + 1, 1)
    end

    mf.flow(s, t).should eq l
  end

  x.report("AtCoder::MaxFlow (long path graph)") do
    n = 100_000_i64
    mf = AtCoder::MaxFlow.new(n)
    (n - 1).times { |i| mf.add_edge(i, i + 1, 1) }
    mf.flow(0, n - 1).should eq 1
  end
end
