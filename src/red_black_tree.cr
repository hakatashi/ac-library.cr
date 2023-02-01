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

# bench_red_black_tree.rb by Rubinius Project, (c) Rubinius Contributors
# https://github.com/rubinius/rubinius-benchmark/blob/master/real_world/bench_red_black_tree.rb
# Licensed under BSD License https://spdx.org/licenses/BSD-3-Clause.html

# red_black_tree.cr by Crystal Language Project, (c) Manas Technology Solutions
# https://github.com/crystal-lang/crystal/blob/master/samples/red_black_tree.cr
# Licensed under MIT License https://mit-license.org

module AtCoder
  class RedBlackTree
    class Node
      property :color
      property :key
      property! :left
      property! :right
      property! parent : self

      RED   = :red
      BLACK = :black

      def initialize(@key : Int32, @color = RED)
        @left = @right = @parent = NilNode.instance
      end

      def black?
        color == BLACK
      end

      def red?
        color == RED
      end

      def nil_node?
        false
      end
    end

    class NilNode < Node
      def self.instance
        @@instance ||= RedBlackTree::NilNode.new
      end

      def initialize
        @key = 0
        @color = BLACK
        @left = @right = @parent = self
      end

      def nil_node?
        true
      end
    end

    include Enumerable(Int32)

    property root : Node
    property :size

    def initialize
      @root = NilNode.instance
      @size = 0
    end

    def insert(key)
      insert_node(Node.new(key))
    end

    def insert_node(x)
      insert_helper(x)

      x.color = Node::RED
      while x != root && x.parent.color == Node::RED
        if x.parent == x.parent.parent.left
          y = x.parent.parent.right
          if !y.nil_node? && y.color == Node::RED
            x.parent.color = Node::BLACK
            y.color = Node::BLACK
            x.parent.parent.color = Node::RED
            x = x.parent.parent
          else
            if x == x.parent.right
              x = x.parent
              left_rotate(x)
            end
            x.parent.color = Node::BLACK
            x.parent.parent.color = Node::RED
            right_rotate(x.parent.parent)
          end
        else
          y = x.parent.parent.left
          if !y.nil_node? && y.color == Node::RED
            x.parent.color = Node::BLACK
            y.color = Node::BLACK
            x.parent.parent.color = Node::RED
            x = x.parent.parent
          else
            if x == x.parent.left
              x = x.parent
              right_rotate(x)
            end
            x.parent.color = Node::BLACK
            x.parent.parent.color = Node::RED
            left_rotate(x.parent.parent)
          end
        end
      end
      root.color = Node::BLACK
    end

    def delete_node(z)
      y = (z.left.nil_node? || z.right.nil_node?) ? z : successor(z)
      x = y.left.nil_node? ? y.right : y.left
      x.parent = y.parent

      if y.parent.nil_node?
        self.root = x
      else
        if y == y.parent.left
          y.parent.left = x
        else
          y.parent.right = x
        end
      end

      z.key = y.key if y != z

      if y.color == Node::BLACK
        delete_fixup(x)
      end

      self.size -= 1
      y
    end

    def minimum_node(x = root)
      while !x.left.nil_node?
        x = x.left
      end
      x
    end

    def maximum_node(x = root)
      while !x.right.nil_node?
        x = x.right
      end
      x
    end

    def successor(x)
      if !x.right.nil_node?
        return minimum_node(x.right)
      end
      y = x.parent
      while !y.nil_node? && x == y.right
        x = y
        y = y.parent
      end
      y
    end

    def predecessor(x)
      if !x.left.nil_node?
        return maximum_node(x.left)
      end
      y = x.parent
      while !y.nil_node? && x == y.left
        x = y
        y = y.parent
      end
      y
    end

    def inorder_walk(x = root, &)
      # ameba:disable Lint/ShadowedArgument
      x = self.minimum_node
      while !x.nil_node?
        yield x.key
        x = successor(x)
      end
    end

    def each(x = root, &)
      inorder_walk(x) { |k| yield k }
    end

    def reverse_inorder_walk(x = root, &)
      # ameba:disable Lint/ShadowedArgument
      x = self.maximum_node
      while !x.nil_node?
        yield x.key
        x = predecessor(x)
      end
    end

    def reverse_each(x = root, &)
      reverse_inorder_walk(x) { |k| yield k }
    end

    def search(key, x = root)
      while !x.nil_node? && x.key != key
        x = (key < x.key) ? x.left : x.right
      end
      x
    end

    def lower_than(key, x = root)
      while !x.nil_node? && x.key != key
        tmp = (key < x.key) ? x.left : x.right
        if tmp.nil_node?
          return x
        end
        x = tmp
      end
      x
    end

    def empty?
      self.root.nil_node?
    end

    def black_height(x = root)
      height = 0
      while !x.nil_node?
        x = x.left
        height += 1 if x.nil_node? || x.black?
      end
      height
    end

    private def left_rotate(x)
      raise "x.right is nil!" if x.right.nil_node?
      y = x.right
      x.right = y.left
      y.left.parent = x if !y.left.nil_node?
      y.parent = x.parent
      if x.parent.nil_node?
        self.root = y
      else
        if x == x.parent.left
          x.parent.left = y
        else
          x.parent.right = y
        end
      end
      y.left = x
      x.parent = y
    end

    private def right_rotate(x)
      raise "x.left is nil!" if x.left.nil_node?
      y = x.left
      x.left = y.right
      y.right.parent = x if !y.right.nil_node?
      y.parent = x.parent
      if x.parent.nil_node?
        self.root = y
      else
        if x == x.parent.left
          x.parent.left = y
        else
          x.parent.right = y
        end
      end
      y.right = x
      x.parent = y
    end

    private def insert_helper(z)
      y = NilNode.instance
      x = root
      while !x.nil_node?
        y = x
        x = (z.key < x.key) ? x.left : x.right
      end
      z.parent = y
      if y.nil_node?
        self.root = z
      else
        z.key < y.key ? y.left = z : y.right = z
      end
      self.size += 1
    end

    # ameba:disable Metrics/CyclomaticComplexity
    private def delete_fixup(x)
      while x != root && x.color == Node::BLACK
        if x == x.parent.left
          w = x.parent.right
          if w.color == Node::RED
            w.color = Node::BLACK
            x.parent.color = Node::RED
            left_rotate(x.parent)
            w = x.parent.right
          end
          if w.left.color == Node::BLACK && w.right.color == Node::BLACK
            w.color = Node::RED
            x = x.parent
          else
            if w.right.color == Node::BLACK
              w.left.color = Node::BLACK
              w.color = Node::RED
              right_rotate(w)
              w = x.parent.right
            end
            w.color = x.parent.color
            x.parent.color = Node::BLACK
            w.right.color = Node::BLACK
            left_rotate(x.parent)
            x = root
          end
        else
          w = x.parent.left
          if w.color == Node::RED
            w.color = Node::BLACK
            x.parent.color = Node::RED
            right_rotate(x.parent)
            w = x.parent.left
          end
          if w.right.color == Node::BLACK && w.left.color == Node::BLACK
            w.color = Node::RED
            x = x.parent
          else
            if w.left.color == Node::BLACK
              w.right.color = Node::BLACK
              w.color = Node::RED
              left_rotate(w)
              w = x.parent.left
            end
            w.color = x.parent.color
            x.parent.color = Node::BLACK
            w.left.color = Node::BLACK
            right_rotate(x.parent)
            x = root
          end
        end
      end
      x.color = Node::BLACK
    end

    def min
      minimum_node.key
    end

    def max
      maximum_node.key
    end

    def delete(key)
      node = search(key)
      unless node.nil_node?
        delete_node(node)
      end
    end

    def has_key?(key)
      node = search(key)
      !node.nil_node?
    end

    def <<(x)
      insert(x)
    end
  end
end
