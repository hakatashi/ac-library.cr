# ac-library.cr by hakatashi https://github.com/hakatashi/ac-library.cr
#
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_6_A

require "./MaxFlow.cr"

nv, ne = read_line.split.map(&.to_i64)
flow = AtCoder::MaxFlow.new(nv)
ne.times do
  u, v, c = read_line.split.map(&.to_i64)
  flow.add_edge(u, v, c)
end
p flow.max_flow(0, nv - 1)