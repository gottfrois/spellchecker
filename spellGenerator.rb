$vowels = %w"a e i o u y"
$nbCharToRepeat = 3
$nbWordsToGenerate = (ARGV[0].nil? ? 100 : ARGV[0].to_i)

# Adding replace method to String class
class String
  def replace(pos, by)
    new = dup
    new[pos] = by
    new
  end
end

# My class, i'm using pointer's methods
class SpellGenerator
  # Repeat x characters on y characters of a word
  def repeatSomeCharacters word
    n = word.length
    rand = (1 + rand(n * 1.2)).round            # Oo why 1.2 ?? why not ?
    res = String.new
    chars = Hash.new
    [*"a".."z"].each { |c|
      i = rand($nbCharToRepeat)                 # Possibly 0 !
      chars[c] = (i == 0 ? c : c*i)
    }
    i = 0
    word.each_char { |c|
      res << (i <= rand && chars.has_key?(c) ? chars[c] : c)
      i += 1
    }
    return res
  end
  
  # Swap x vowels of a word by a random new one
  def swapVowels word
    n = $vowels.length
    chars = Hash.new
    $vowels.each { |c|
      i = rand(n)
      chars[c] = ($vowels.shuffle)[i]
    }
    res = String.new
    word.each_char { |c|
      res << (chars.has_key?(c) ? chars[c] : c)
    }
    return res
  end
  
  # Upper a random number of characters in a word
  def upperized word
    res = String.new
    word.each_char { |c|
      i = rand(2)
      res << (i == 0 ? c.upcase : c)
    }
    return res
  end
end

#----------------------------------------------------------------

# Load our words dictionary and keep only words with length <= maxWordSize
def loadDictionary
  words = Array.new
  fd = File.new('/usr/share/dict/words')
  while ((s = fd.gets) != nil)
    words << s
  end
  return words
end

# Main method who apply a least one transformation to x words.
# 16% chance to apply one more transformation (it can be the same)
# Every word MUST have '\n' and program.
def generateMisspeldWords words
  words.shuffle!
  words.take($nbWordsToGenerate).each { |w|
    i = rand(3)
    i2 = rand(15)
    w.downcase!
    w.chomp!
    w = FP[i].call(w)
    w = FP[i2].call(w) if !FP[i2].nil?          # 20% chance to happen
    puts w
  }
end

m = SpellGenerator.new

DICT = loadDictionary
FP = [m.method(:upperized), m.method(:swapVowels), m.method(:repeatSomeCharacters)]

generateMisspeldWords(DICT)
print "\0"                                      # SHOULD print '\0' to tell SpellChecker to quit.
