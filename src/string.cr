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
  module String
    private SA_THRESHOLD_NAIVE    = 10
    private SA_THRESHOLD_DOUBLING = 40

    private def self.sa_naive(s)
      n = s.size
      sa = (0...n).to_a.sort { |l, r|
        next 1 if l == r
        res = nil
        while l < n && r < n
          if s[l] != s[r]
            res = s[l] <=> s[r]
            break
          end
          l += 1
          r += 1
        end
        res ? res : (l == n ? -1 : 1)
      }
      sa
    end

    private def self.sa_doubling(s)
      n = s.size
      sa = (0...n).to_a
      rank = s.clone
      tmp = [0] * n

      k = 1
      while k < n
        cmp = ->(x : Int32, y : Int32) {
          return rank[x] <=> rank[y] if rank[x] != rank[y]
          rx = x + k < n ? rank[x + k] : -1
          ry = y + k < n ? rank[y + k] : -1
          rx <=> ry
        }

        sa.sort! { |a, b| cmp.call(a, b) }
        tmp[sa[0]] = 0
        (1...n).each do |i|
          tmp[sa[i]] = tmp[sa[i - 1]] + (cmp.call(sa[i - 1], sa[i]) == -1 ? 1 : 0)
        end

        tmp, rank = rank, tmp

        k *= 2
      end

      sa
    end

    # ameba:disable Metrics/CyclomaticComplexity
    private def self.sa_is(s, upper)
      n = s.size

      case n
      when .==(0)
        return [] of Int32
      when .==(1)
        return [0]
      when .==(2)
        return s[0] < s[1] ? [0, 1] : [1, 0]
      when .<(SA_THRESHOLD_NAIVE)
        return sa_naive(s)
      when .<(SA_THRESHOLD_DOUBLING)
        return sa_doubling(s)
      end

      sa = [0] * n
      ls = [false] * n
      (n - 2).downto(0) do |i|
        ls[i] = s[i] == s[i + 1] ? ls[i + 1] : s[i] < s[i + 1]
      end

      sum_l = [0] * (upper + 1)
      sum_s = [0] * (upper + 1)
      n.times do |i|
        if ls[i]
          sum_l[s[i] + 1] += 1
        else
          sum_s[s[i]] += 1
        end
      end

      (0..upper).each do |i|
        sum_s[i] += sum_l[i]
        sum_l[i + 1] += sum_s[i] if i < upper
      end

      induce = ->(lms : Array(Int32)) do
        sa = [-1] * n
        buffer = sum_s.clone
        lms.each do |d|
          next if d == n
          sa[buffer[s[d]]] = d
          buffer[s[d]] += 1
        end

        buffer = sum_l.clone
        sa[buffer[s[n - 1]]] = n - 1
        buffer[s[n - 1]] += 1
        n.times do |i|
          v = sa[i]
          if v >= 1 && !ls[v - 1]
            sa[buffer[s[v - 1]]] = v - 1
            buffer[s[v - 1]] += 1
          end
        end

        buffer = sum_l.clone
        (n - 1).downto(0) do |i|
          v = sa[i]
          if v >= 1 && ls[v - 1]
            buffer[s[v - 1] + 1] -= 1
            sa[buffer[s[v - 1] + 1]] = v - 1
          end
        end
      end

      lms_map = [-1] * (n + 1)
      m = 0
      (1...n).each do |i|
        if !ls[i - 1] && ls[i]
          lms_map[i] = m
          m += 1
        end
      end

      lms = Array(Int32).new(m)
      (1...n).each do |i|
        if !ls[i - 1] && ls[i]
          lms << i
        end
      end

      induce.call(lms)

      return sa if m == 0

      sorted_lms = Array(Int32).new(m)
      sa.each do |v|
        sorted_lms << v if lms_map[v] != -1
      end

      rec_s = [0] * m
      rec_upper = 0
      rec_s[lms_map[sorted_lms[0]]] = 0
      (1...m).each do |i|
        l = sorted_lms[i - 1]
        r = sorted_lms[i]
        end_l = (lms_map[l] + 1 < m) ? lms[lms_map[l] + 1] : n
        end_r = (lms_map[r] + 1 < m) ? lms[lms_map[r] + 1] : n

        same = true
        if end_l - l != end_r - r
          same = false
        else
          while l < end_l
            break if s[l] != s[r]
            l += 1
            r += 1
          end
          same = false if l == n || s[l] != s[r]
        end
        rec_upper += 1 unless same
        rec_s[lms_map[sorted_lms[i]]] = rec_upper
      end

      rec_sa = sa_is(rec_s, rec_upper)

      m.times do |i|
        sorted_lms[i] = lms[rec_sa[i]]
      end

      induce.call(sorted_lms)
      sa
    end

    # returns suffix array in O(n + upper)
    def self.suffix_array(sequence : Indexable(Int32), upper)
      sa_is(sequence, upper)
    end

    # returns suffix array in O(n log(n))
    def self.suffix_array(sequence : Indexable)
      n = sequence.size
      indices = (0...n).to_a.sort { |l, r| sequence[l] <=> sequence[r] }
      s2 = [0] * n
      now = 0
      n.times do |i|
        now += 1 if i > 0 && sequence[indices[i - 1]] != sequence[indices[i]]
        s2[indices[i]] = now
      end
      upper = now
      sa_is(s2, upper)
    end

    # returns suffix array in O(n)
    def self.suffix_array(sequence : ::String)
      sa_is(sequence.bytes.map(&.to_i32), 255)
    end

    # returns lcp array in O(n)
    def self.lcp_array(sequence, sa)
      n = sequence.size
      rank = [0] * n
      sa.each_with_index { |e, i| rank[e] = i }

      lcp = [0] * (n - 1)
      h = 0
      n.times do |i|
        h -= 1 if h > 0
        next if rank[i] == 0
        j = sa[rank[i] - 1]
        while j + h < n && i + h < n
          break if sequence[j + h] != sequence[i + h]
          h += 1
        end
        lcp[rank[i] - 1] = h
      end

      lcp
    end

    # returns z array
    def self.z_algorithm(sequence)
      n = sequence.size
      return [] of Int32 if n == 0
      z = [0] * n
      i, j = 1, 0
      while i < n
        z[i] = (j + z[j] <= i) ? 0 : (j + z[j] - i < z[i - j] ? j + z[j] - i : z[i - j])
        while i + z[i] < n && sequence[z[i]] == sequence[i + z[i]]
          z[i] += 1
        end
        j = i if j + z[j] < i + z[i]
        i += 1
      end
      z[0] = n
      z
    end
  end
end
