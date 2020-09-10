# verify-helper: PROBLEM https://judge.yosupo.jp/problem/unionfind

require "./UnionFindTree.cr"

n, q = read_line.split.map(&.to_i64)
tree = UnionFindTree.new(n)

q.times do
  t, u, v = read_line.split.map(&.to_i64)
  if t == 0
    tree.unite(u, v)
  else
    if tree.same(u, v)
      p 1
    else
      p 0
    end
  end
end
