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

require "../src/two_sat.cr"
require "spec"

alias TwoSat = AtCoder::TwoSat

private def satisfies?(assignment, clauses)
  clauses.all? { |(i, f, j, g)| assignment[i] == f || assignment[j] == g }
end

private def naive_satisfiable?(n, clauses)
  (0...(1 << n)).any? do |mask|
    satisfies?(Array.new(n) { |i| mask.bit(i) == 1 }, clauses)
  end
end

describe "TwoSat" do
  describe "#satisfiable?" do
    it "returns true for a formula without clauses" do
      TwoSat.new(3_i64).satisfiable?.should be_true
      TwoSat.new(0_i64).satisfiable?.should be_true
    end

    it "returns false for contradicting unit clauses" do
      twosat = TwoSat.new(2_i64)
      twosat.add_clause(0, true, 0, true)
      twosat.add_clause(0, false, 1, true)
      twosat.add_clause(1, false, 1, false)
      twosat.satisfiable?.should be_false
    end

    it "matches a naive implementation on random small formulas" do
      rng = Random.new(36)
      500.times do
        n = rng.rand(1..6)
        clauses = Array.new(rng.rand(0..12)) do
          {rng.rand(n), rng.rand < 0.5, rng.rand(n), rng.rand < 0.5}
        end

        twosat = TwoSat.new(n.to_i64)
        clauses.each { |(i, f, j, g)| twosat.add_clause(i, f, j, g) }
        expected = naive_satisfiable?(n, clauses)
        twosat.satisfiable?.should eq expected
        if expected
          answer = twosat.answer
          answer.size.should eq n
          satisfies?(answer, clauses).should be_true
        end
      end
    end
  end

  describe "#answer" do
    it "returns an empty array for zero variables" do
      TwoSat.new(0_i64).answer.should eq [] of Bool
    end

    it "returns an assignment after #satisfiable?" do
      twosat = TwoSat.new(2_i64)
      twosat.add_clause(0, true, 1, false)
      twosat.add_clause(1, true, 0, false)
      twosat.add_clause(0, false, 1, false)
      twosat.satisfiable?.should be_true
      twosat.answer.should eq [false, false]
    end

    it "solves the formula without calling #satisfiable? beforehand" do
      twosat = TwoSat.new(2_i64)
      twosat.add_clause(0, true, 1, false)
      twosat.add_clause(1, true, 0, false)
      twosat.add_clause(0, false, 1, false)
      twosat.answer.should eq [false, false]
    end

    it "re-solves the formula when clauses are added after solving" do
      twosat = TwoSat.new(1_i64)
      twosat.add_clause(0, true, 0, true)
      twosat.answer.should eq [true]
      twosat.add_clause(0, false, 0, false)
      expect_raises(TwoSat::NotSatisfiableError) { twosat.answer }
    end

    it "raises NotSatisfiableError if the formula is not satisfiable" do
      twosat = TwoSat.new(1_i64)
      twosat.add_clause(0, true, 0, true)
      twosat.add_clause(0, false, 0, false)
      twosat.satisfiable?.should be_false
      expect_raises(TwoSat::NotSatisfiableError) { twosat.answer }
    end
  end
end
