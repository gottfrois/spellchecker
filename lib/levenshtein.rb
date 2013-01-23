module Levenshtein

  module_function

  def check(s, t)
    n = s.length
    m = t.length
    return m if (0 == n)
    return n if (0 == m)

    d = (0..m).to_a
    x = nil

    (0...n).each do |i|
      e = i+1
      (0...m).each do |j|
        cost = (s[i] == t[j]) ? 0 : 1
        x = [
             d[j+1] + 1, # insertion
             e + 1,      # deletion
             d[j] + cost # substitution
            ].min
        d[j] = e
        e = x
      end
      d[m] = x
    end
    return x
  end
end
