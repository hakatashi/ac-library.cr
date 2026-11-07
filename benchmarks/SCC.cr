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

require "../src/scc.cr"
require "../src/two_sat.cr"
require "benchmark"
require "spec"

Benchmark.bm do |x|
  # O(n + m)
  x.report("AtCoder::SCC (random)") do
    n = 500_000_i64
    rng = Random.new(28)

    scc = AtCoder::SCC.new(n)
    n.times do
      scc.add_edge(rng.rand(n), rng.rand(n))
    end

    groups = scc.scc
    groups.sum(&.size).should eq n
  end

  # O(n + m)
  x.report("AtCoder::SCC (cycle)") do
    n = 500_000_i64

    scc = AtCoder::SCC.new(n)
    n.times do |i|
      scc.add_edge(i, (i + 1) % n)
    end

    scc.scc.size.should eq 1
  end

  # O(n + m)
  x.report("AtCoder::TwoSat") do
    n = 500_000_i64
    rng = Random.new(28)
    answer = Array.new(n) { rng.next_bool }

    twosat = AtCoder::TwoSat.new(n)
    n.times do
      i = rng.rand(n)
      j = rng.rand(n)
      # Each clause is satisfied by `answer` through its first literal.
      twosat.add_clause(i, answer[i], j, rng.next_bool)
    end

    twosat.satisfiable?.should be_true
  end
end
