# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2023 Google LLC
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

module AtCoder
  class SkewHeap(T)
    @root : Node(T) | Nil
    @size : Int64

    getter :size

    class Node(T)
      @left : Node(T) | Nil
      @right : Node(T) | Nil
      @value : T

      property :value, :left, :right

      def initialize(@left, @right, @value)
      end
    end

    def initialize
      initialize { |a, b| a <= b }
    end

    def initialize(&block : T, T -> Bool)
      @root = nil
      @size = 0_i64
      @compare_proc = block
    end

    def meld(a : Node(T) | Nil, b : Node(T) | Nil)
      return b if a.nil?
      return a if b.nil?
      if @compare_proc.call(a.value, b.value)
        a, b = b, a
      end
      a.right = meld(a.right, b)
      a.left, a.right = a.right, a.left
      a
    end

    def push(value : T)
      @root = meld(@root, Node(T).new(nil, nil, value))
      @size += 1
    end

    def pop
      return nil if @root.nil?
      root = @root.not_nil!
      ret = root.value
      @root = meld(root.left, root.right)
      @size -= 1
      ret
    end

    # Alias of `push`
    def <<(v : T)
      push(v)
    end

    def empty?
      @size == 0
    end
  end
end
