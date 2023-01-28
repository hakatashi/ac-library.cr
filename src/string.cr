module AtCoder
  module String
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
