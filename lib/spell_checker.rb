# @author Pierre-Louis Gottfrois http://fr.linkedin.com/in/pierrelouisgottfrois/
module SpellChecker

  class << self; attr_accessor :dictionary; end

  @dictionary = {}

  module_function

  # Load dictionary at given path into memory.
  #
  # @param [String] from the path to dictionary.
  def initialize_dictionary(from)
    ('a'..'z').each { |c| self.dictionary[c] = [] }
    File.new(from).readlines.each do |l|
      w = l.downcase.chomp
      self.dictionary[w[0]] << w
    end
  end

  # Spell check given word.
  #
  # @param [String] word the word to spell check.
  # @return [String] the spell checked word.
  def spell_check(word)

    return 'NO SUGGESTION' if word.nil? || word.empty?

    # Try against dictionary < O(n)
    return word if find(word)

    # Build regex and try againt dictionary < O(n)
    candidates = try_with_regex(word)
    return candidates if candidates.is_a?(String)

    # Compute Levenshtein distance between word and regex candidates
    # From instructions: "If there are many possible corrections of an input
    # word, your program can choose one in any way you like."
    result = try_with_distance(word, candidates)
    return result if result

    'NO SUGGESTION'
  end

  # Look for given word into dictionary.
  #
  # @param [String] word the word to spell check.
  # @return [true, false] whether word is in dictionary or not.
  def find(word)
    if %w(a e i o u y).include?(word[0])
      self.dictionary.select {|k,v| k =~ /[aeiouy]/}.values.flatten
    else
      self.dictionary[word[0]]
    end.include?(word)
  end

  # Look for given word into dictionary based on regex.
  #
  # @param [String] word the word to spell check.
  # @return [Array<String>] candidates maching regex.
  def try_with_regex(word)
    regex = build_regex(word)
    if %w(a e i o u y).include?(word[0])
      self.dictionary.select {|k,v| k =~ /[aeiouy]/}.values.flatten
    else
      self.dictionary[word[0]]
    end.map do |w|
      result = regex.match(w)
      result[0] if result
    end.compact
  end

  # Build a regex based on given word removing duplicates.
  #
  # @param [String] word the word to spell check.
  # @return [Regexp] the word based regex.
  def build_regex(word)
    regex = '^(?:'
    regex << word.squeeze.gsub(/(?<char>[bcdfghjklmnpqrstvwxz])/, '\k<char>+')
    regex.gsub!(/[aeiouy]/, 'a')
    regex.squeeze!
    regex.gsub!(/[a]/, '[aeiouy]+')
    regex << ')$'
    Regexp.new(regex)
  end

  # Compute Levenshtein distance between given word and a given list of candidates.
  #
  # @param [String] word the word to spell check.
  # @param [Array] candidates the array of candidates to run Levenshtein against.
  # @return [String] the 'closest' word from given word.
  def try_with_distance(word, candidates)
    t = +1.0/0.0
    result = nil
    candidates.each {|w|
      d = Levenshtein.check(w, word)
      if d < t
        t = d
        result = w
      end
    }

    result
  end

  # Display a regular prompt where user can type a word to spellcheck.
  #
  # @raise [Exception] if user hit 'ctrl+c'.
  def show_prompt
    word = ''
    prompt = lambda { print '>'; $stdout.flush }

    # Show '>' the first time
    prompt.call

    begin
      until false
        if $stdin.ready?
          char = $stdin.getc
          case char
          when ?\C-c, ?\0, 48
            puts "\r\n"
            break
          when ?\r, ?\n
            puts spell_check(word.downcase) unless word.empty?
            word = ''
            prompt.call
          else
            word << char
            $stdout.flush
          end
        end
      end
    rescue Exception
      puts ''
      puts 'Good Bye'
    end
  end

end
