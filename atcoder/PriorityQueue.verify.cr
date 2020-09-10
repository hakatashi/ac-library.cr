# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_9_C

require "./PriorityQueue.cr"

q = PriorityQueue(Int64).new
loop do
  tokens = read_line.split
  if tokens[0] == "insert"
    q << tokens[1].to_i64
  elsif tokens[0] == "extract"
    p q.pop
  else
    exit
  end
end
