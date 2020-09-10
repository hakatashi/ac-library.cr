require "./UnionFindTree.cr"
require "spec"

describe "UnionFindTree" do
  describe "#unite" do
    it "unifies group of trees into unions" do
      tree = UnionFindTree.new(9)

      tree.unite(0, 2)
      tree.unite(2, 4)
      tree.unite(4, 6)

      tree.unite(7, 1)
      tree.unite(7, 3)
      tree.unite(7, 5)

      tree.same(2, 6).should eq true
      tree.same(4, 2).should eq true
      tree.same(1, 3).should eq true
      tree.same(3, 5).should eq true
      tree.same(8, 8).should eq true
      tree.same(2, 1).should eq false
      tree.same(7, 0).should eq false
      tree.same(5, 4).should eq false
      tree.same(8, 7).should eq false

      tree.size(4).should eq 4
      tree.size(1).should eq 4
      tree.size(8).should eq 1
    end
  end
end