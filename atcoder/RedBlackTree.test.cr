require "./RedBlackTree.cr"
require "spec"

describe "RedBlackTree" do
  it "pops values in priority order" do
    tree = RedBlackTree.new
    tree << 5
    tree << 6
    tree << 1
    tree << 3
    tree << 2
    tree << 8
    tree << 7
    tree << 4
    tree.max.should eq 8
    tree.min.should eq 1

    tree.delete 1
    tree.delete 5
    tree.delete 8

    tree.max.should eq 7
    tree.min.should eq 2
  end

  describe "#empty?" do
    it "should report true if queue is empty" do
      tree = RedBlackTree.new
      tree.empty?.should eq true
      tree << 1
      tree.empty?.should eq false
      tree.delete 1
      tree.empty?.should eq true
    end
  end
end