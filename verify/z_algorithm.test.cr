# verification: PROBLEM https://judge.yosupo.jp/problem/zalgorithm

require "../src/string.cr"

s = read_line
puts AtCoder::String.z_algorithm(s).join(" ")
