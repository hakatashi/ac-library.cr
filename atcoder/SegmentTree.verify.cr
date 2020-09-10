# verify-helper: PROBLEM https://judge.yosupo.jp/problem/point_add_range_sum

require "./SegmentTree.cr"

n, q = read_line.split.map(&.to_i64)
ais = read_line.split.map(&.to_i64)
tree = SegmentTree.new(ais) {|a, b| a + b}

q.times do
  args = read_line.split.map(&.to_i64)
  if args[0] == 0
    _, p, x = args
    tree[p] = tree[p] + x
  else
    _, l, r = args
    p tree[l...r]
  end
end
