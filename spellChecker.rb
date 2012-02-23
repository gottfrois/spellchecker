load "inc/levenshtein.rb"
include Levenshtein
require "io/wait"

# Load our dictionary in memory
def loadDictionary
  print "Reading dictionary file...\t\t"
  hash = Hash.new(1)
  File.new('/usr/share/dict/words').readlines.each {|l|
    l.downcase!
    l.chomp!
    hash[l] += 1 # Not used here, but could be if I used a text instead of a dictionnary
  }
  puts "Done."
  return hash
end

# Try to find candidates into our words' hash
def try words
  return nil if words.nil?
  res = words.find_all { |w|
    DICT.has_key?(w)
  }
  return res.empty? ? nil : res
end

# Calculate the number of opperations needed to match our word
# with a candidates list
def tryDistance word, candidates
  return nil if candidates.nil?
  tmp = 1234567890
  res = nil
  candidates.each { |w|
    i = Levenshtein.levenshtein(w, word)
    if i < tmp
      tmp = i
      res = w
    end
  }
  return res
end

# Foreach word in the dictionnary, match the regex
def tryRegex regex
  return nil if regex.nil?
  res = Array.new
  DICT.each {|k,v|
    tmp = regex.match(k)
    res << tmp[0] if !tmp.nil?
  }
  return res
end

# Create a regex base on a word
# Replace vowels by [aeiouy]+ and other the characters by TheChar+
def generatesRegex word
  return nil if word.nil? || word.empty?
  vowels = {0=>'a',1=>'e',2=>'i',3=>'o',4=>'u',5=>'y'}
  regex = String.new("^(?:")
  lastChar = ''
  word.each_char {|c|
    if vowels.has_value?(c)
      regex << "[aeiouy]+" if lastChar != c && !vowels.has_value?(lastChar)
    else
      regex << "#{c}+" if lastChar != c
    end
    lastChar = c
  }
  regex << ")$"
  return Regexp.new(regex)
end

# Main method, applying every algorithm
def correct word
  # I try to find the word in our dictionnary.
  candidates = try(word)
  return candidates if !candidates.nil?

  # I try to find candidates with a regex base on the wrong word.
  candidates = tryRegex(generatesRegex(word))
  return candidates if !candidates.nil? && candidates.size == 1

  # I calculate the number of opperations neeeded to find our word. I use the candidates found by the regex method.
  candidates = (tryDistance(word, candidates))
  return candidates if !candidates.nil?

  # Failed, no match found...
  return "NO SUGGESTION"
end

ostream = String.new
DICT    = loadDictionary

# Starting point. Show a prompt
def show_prompt
  print ">"
  $stdout.flush
end

show_prompt

until false
  if $stdin.ready?
    c = $stdin.getc
    case c
    when ?\C-c, ?\0, 48
      puts "\r\n"
      break;
    when ?\r, ?\n
      puts correct(ostream.downcase) if !ostream.empty?
      ostream = ''
      show_prompt
    else
      ostream << c
      $stdout.flush
    end
  end

end
