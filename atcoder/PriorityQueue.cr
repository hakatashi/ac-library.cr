# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2021 Google LLC
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
      initialize(&.itself)
    end

    # Initializes queue with the custom comperator.
    #
    # ```
    # q = AtCoder::PriorityQueue(Int64).new {|n| -n}
    # q << 1_i64
    # q << 3_i64
    # q << 2_i64
    # q.pop # => 1
    # q.pop # => 2
    # q.pop # => 3
    # ```
    def initialize(&block : T -> (Int8 | Int16 | Int32 | Int64 | UInt8 | UInt16 | UInt32 | UInt64))
      @heap = Array(T).new
      @priority_proc = block
    end

    # Pushes value into the queue.
    def push(v : T)
      @heap << v
      index = @heap.size - 1
      while index != 0
        parent = (index - 1) // 2
        if @priority_proc.call(@heap[parent]) >= @priority_proc.call(@heap[index])
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
        child = if index * 2 + 2 < @heap.size && @priority_proc.call(@heap[index * 2 + 1]) < @priority_proc.call(@heap[index * 2 + 2])
          index * 2 + 2
        else
          index * 2 + 1
        end
        if @priority_proc.call(@heap[index]) >= @priority_proc.call(@heap[child])
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
