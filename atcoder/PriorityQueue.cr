# PriorityQueue.cr by Koki Takahashi
# Licensed under MIT License https://mit-license.org

class PriorityQueue(T)
  property heap : Array(T)

  def initialize
    initialize(&.itself)
  end

  def initialize(&block : T -> (Int8 | Int16 | Int32 | Int64 | UInt8 | UInt16 | UInt32 | UInt64))
    @heap = Array(T).new
    @priority_proc = block
  end

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

  def <<(v : T)
    push(v)
  end

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

  delegate :empty?, to: @heap
end
