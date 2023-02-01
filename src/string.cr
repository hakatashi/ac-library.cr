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
