require "./RedBlackTree.cr"
require "spec"

describe "RedBlackTree" do
  describe "bench" do 
    # O(nlogn)
    it "should finish" do
      n = 500000
      tree = RedBlackTree.new
      n.times do |i|
        tree << i
        tree << i + n
        tree << i + n * 2
      end
      (n * 3).times do |i|
        tree.has_key?(n * 3 - i - 1).should eq true
        tree.max.should eq n * 3 - i - 1
        tree.delete(n * 3 - i - 1)
      end
      tree.empty?.should eq true
    end
  end
end