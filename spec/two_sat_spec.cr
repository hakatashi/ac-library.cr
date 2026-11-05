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

require "../src/two_sat.cr"
require "spec"

alias TwoSat = AtCoder::TwoSat

describe "TwoSat" do
  describe "#answer" do
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
