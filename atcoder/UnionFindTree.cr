# UnionFindTree.cr by Koki Takahashi
# Licensed under MIT License https://mit-license.org

class UnionFindTree
  property parents : Array(Int32)
  property sizes : Array(Int32)

  def initialize(size)
    @parents = Array.new(size, &.to_i32)
    @sizes = Array.new(size, 1)
  end

  def root(node)
    until @parents[node] == node
      @parents[node] = @parents[@parents[node]]
      node = @parents[node]
    end
    node
  end

  def unite(a, b)
    root_a = root(a.to_i32)
    root_b = root(b.to_i32)
    unless root_a == root_b
      if @sizes[root_a] < @sizes[root_b]
        root_a, root_b = root_b, root_a
      end
      @parents[root_b] = root_a
      @sizes[root_a] += @sizes[root_b]
    end
  end

  def same(a, b)
    root(a) == root(b)
  end

  def size(node)
    @sizes[root(node)]
  end
end
