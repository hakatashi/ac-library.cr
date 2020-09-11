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
