require "./PriorityQueue.cr"
require "spec"

describe "PriorityQueue" do
  describe "bench" do 
    # O(nlogn)
    it "should finish" do
      n = 500000
      q = PriorityQueue(Int32).new
      n.times do |i|
        q << i
        q << i + n
        q << i + n * 2
      end
      (n * 3).times do |i|
        q.pop.should eq n * 3 - i - 1
      end
    end
  end
end