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

require "../src/priority_queue.cr"
require "spec"

alias PriorityQueue = AtCoder::PriorityQueue

describe "PriorityQueue" do
  it "pops values in priority order" do
    q = PriorityQueue(Int32).new
    q << 5
    q << 6
    q << 1
    q << 3
    q << 2
    q << 8
    q << 7
    q << 4
    q.pop.should eq 8
    q.pop.should eq 7
    q.pop.should eq 6
    q.pop.should eq 5
    q.pop.should eq 4
    q.pop.should eq 3
    q.pop.should eq 2
    q.pop.should eq 1
    q.pop.should eq nil
  end

  it "initialized by elements in *enumerable*" do
    q = PriorityQueue.max([5, 6, 1, 3, 2, 8, 7, 4])
    q.pop.should eq 8
    q.pop.should eq 7
    q.pop.should eq 6
    q.pop.should eq 5
    q.pop.should eq 4
    q.pop.should eq 3
    q.pop.should eq 2
    q.pop.should eq 1
    q.pop.should eq nil
  end

  describe "with custom compare function" do
    it "pops values in priority order" do
      q = PriorityQueue(Int32).new { |a, b| a >= b }
      q << 5
      q << 6
      q << 1
      q << 3
      q << 2
      q << 8
      q << 7
      q << 4
      q.pop.should eq 1
      q.pop.should eq 2
      q.pop.should eq 3
      q.pop.should eq 4
      q.pop.should eq 5
      q.pop.should eq 6
      q.pop.should eq 7
      q.pop.should eq 8
      q.pop.should eq nil
    end
  end

  describe ".max" do
    it "pops values in ascending order of priority" do
      q = PriorityQueue(Int32).max
      q << 5
      q << 6
      q << 1
      q << 3
      q << 2
      q << 8
      q << 7
      q << 4
      q.pop.should eq 8
      q.pop.should eq 7
      q.pop.should eq 6
      q.pop.should eq 5
      q.pop.should eq 4
      q.pop.should eq 3
      q.pop.should eq 2
      q.pop.should eq 1
      q.pop.should eq nil
    end
  end

  describe ".min" do
    it "pops values in descending order of priority" do
      q = PriorityQueue(Int32).min
      q << 5
      q << 6
      q << 1
      q << 3
      q << 2
      q << 8
      q << 7
      q << 4
      q.pop.should eq 1
      q.pop.should eq 2
      q.pop.should eq 3
      q.pop.should eq 4
      q.pop.should eq 5
      q.pop.should eq 6
      q.pop.should eq 7
      q.pop.should eq 8
      q.pop.should eq nil
    end
  end

  describe "#each" do
    it "yields each item in the queue in comparator's order." do
      array = [5, 6, 1, 3, 2, 8, 7, 4]
      sorted = array.sort.reverse!

      q = PriorityQueue.new(array)

      i = 0
      q.each do |x|
        x.should eq sorted[i]
        i += 1
      end
    end
  end

  describe "#first" do
    it "returns, but does not remove, the head of the queue." do
      q = PriorityQueue(Int32).new
      q << 5
      q << 6
      q << 1
      q << 3
      q.first.should eq 6
      q.first.should eq 6
      q.pop.should eq 6
      q.first.should eq 5
      q.pop.should eq 5
      q.first.should eq 3
      q.pop.should eq 3
      q.first.should eq 1
      q.pop.should eq 1
      q.first?.should eq nil
      q.pop.should eq nil
    end
  end

  describe "#empty?" do
    it "should report true if queue is empty" do
      q = PriorityQueue(Int32).new
      q.empty?.should eq true
      q << 1
      q.empty?.should eq false
      q.pop
      q.empty?.should eq true
    end
  end

  describe "#size" do
    it "returns size of the queue" do
      q = PriorityQueue(Int32).new
      q << 1
      q << 1
      q << 1
      q << 1
      q.size.should eq 4
    end
  end
end
