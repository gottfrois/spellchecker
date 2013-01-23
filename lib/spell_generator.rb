# @author Pierre-Louis Gottfrois http://fr.linkedin.com/in/pierrelouisgottfrois/

# Let's add some methods to the String class.
# Note: I used Kernel class for rands, puts and print to write easiest specs.
class String

  # Uppercase random characters of given string.
  #
  # @return [String] the string with random characters uppercased.
  def upperized!
    self.length.times {|i| self[i] = self[i].upcase if Kernel.rand(2) == 0}
    self
  end

  # Swap random vowels of given string.
  #
  # @return [String] the string with random vowels swaped.
  def swap_vowel!
    vowels = %w(a e i o u y)
    self.length.times {|i| self[i] = vowels.shuffle[Kernel.rand(vowels.length)] if vowels.include?(self[i])}
    self
  end

  # Duplicate random characters of given string.
  #
  # @return [String] the string with random characters duplicated.
  def duplicate!
    i = 0
    while self[i] do
      self[i] += self[i] * Kernel.rand(2) if i <= Kernel.rand(self.length)
      i += 1
    end
    self
  end

end

class SpellGenerator

  attr_accessor :nb_word, :dictionary

  # Initialize dictionary and nb_word attributes.
  #
  # @param [String] from the path to dictionary.
  def initialize(from)
    @dictionary = []
    @nb_word = 100
    initialize_dictionary(from)
  end

  # Generate given number of misspelled words base on instructions mistakes.
  #
  # @param [Integer] nb_word the number of misspelled word to generate.
  def generate(nb_word = nil)
    n = (nb_word || self.nb_word).to_i

    self.dictionary.shuffle.take(n).each do |w|
      w = w.downcase.chomp

      methods = [w.method(:upperized!), w.method(:swap_vowel!), w.method(:duplicate!)]
      begin
        methods[Kernel.rand(3)].call
        methods[Kernel.rand(15)].call
      rescue
        # Just to ignore nil.call above
      end

      Kernel.puts w
    end
    Kernel.print "\0"
  end

  private

  # Load dictionary at given path into memory.
  #
  # @param [String] from the path to dictionary.
  def initialize_dictionary(from)
    File.new(from).readlines.each do |l|
      self.dictionary << l.downcase.chomp
    end
  end

end
