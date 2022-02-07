# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2022 Google LLC
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
  # Implements standard priority queue like [std::priority_queue](https://en.cppreference.com/w/cpp/container/priority_queue).
  #
  # ```
  # q = AtCoder::PriorityQueue(Int64).new
  # q << 1_i64
  # q << 3_i64
  # q << 2_i64
  # q.pop # => 3
  # q.pop # => 2
  # q.pop # => 1
  # ```
  class PriorityQueue(T)
    getter heap : Array(T)

    def initialize
      initialize {|a, b| a <= b}
    end

    # Initializes queue with the custom comperator.
    #
    # If the second argument `b` should be popped earlier than
    # the first argument `a`, return `true`. Else, return `false`.
    #
    # ```
    # q = AtCoder::PriorityQueue(Int64).new {|a, b| a >= b}
    # q << 1_i64
    # q << 3_i64
    # q << 2_i64
    # q.pop # => 1
    # q.pop # => 2
    # q.pop # => 3
    # ```
    def initialize(&block : T, T -> Bool)
      @heap = Array(T).new
      @compare_proc = block
    end

    # Pushes value into the queue.
    def push(v : T)
      @heap << v
      index = @heap.size - 1
      while index != 0
        parent = (index - 1) // 2
        if @compare_proc.call(@heap[index], @heap[parent])
          break
        end
        @heap[parent], @heap[index] = @heap[index], @heap[parent]
        index = parent
      end
    end

    # Alias of `push`
    def <<(v : T)
      push(v)
    end

    # Pops value from the queue.
    def pop
      if @heap.size == 0
        return nil
      end
      if @heap.size == 1
        return @heap.pop
      end
      ret = @heap.first
      @heap[0] = @heap.pop
      index = 0
      while index * 2 + 1 < @heap.size
        child = if index * 2 + 2 < @heap.size && !@compare_proc.call(@heap[index * 2 + 2], @heap[index * 2 + 1])
          index * 2 + 2
        else
          index * 2 + 1
        end
        if @compare_proc.call(@heap[child], @heap[index])
          break
        end
        @heap[child], @heap[index] = @heap[index], @heap[child]
        index = child
      end
      ret
    end

    # Returns `true` if the queue is empty.
    delegate :empty?, to: @heap

    # Returns size of the queue.
    delegate :size, to: @heap
  end
end
