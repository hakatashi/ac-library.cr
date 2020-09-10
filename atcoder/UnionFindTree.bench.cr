require "./UnionFindTree.cr"
require "spec"

describe "UnionFindTree" do
  describe "bench" do
    # O(nlogn)
    it "should finish" do
      n = 1000000

      tree = UnionFindTree.new((n + 1) * 3)
      (0...n).to_a.shuffle.each do |i|
        tree.unite(i * 3, (i + 1) * 3)
        tree.unite(i * 3 + 1, (i + 1) * 3 + 1)
        tree.unite(i * 3 + 2, (i + 1) * 3 + 2)
      end

      tree.size(n * 3).should eq n + 1
      tree.size(n * 3 + 1).should eq n + 1
      tree.size(n * 3 + 2).should eq n + 1

      n.times do |i|
        tree.same(0, i * 3 + 1).should eq false
        tree.same(1, i * 3 + 2).should eq false
        tree.same(2, i * 3 + 2).should eq true
      end

      tree.unite(0, 1)
      tree.unite(1, 2)

      tree.size(n // 2).should eq (n + 1) * 3
    end
  end
end