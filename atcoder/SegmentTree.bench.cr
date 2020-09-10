require "./SegmentTree.cr"
require "spec"

describe "SegmentTree" do
  describe "bench" do 
    # O(nlogn)
    it "should finish" do
      n = 1000000
      segtree = SegmentTree.new((1..n).to_a)
      n.times do |i|
        segtree[0..i].should eq i + 1
      end
    end
  end
end