# @author Pierre-Louis Gottfrois http://fr.linkedin.com/in/pierrelouisgottfrois/

require 'levenshtein'
require 'spell_checker'

describe SpellChecker do

  it { should respond_to(:dictionary) }
  it { should respond_to(:initialize_dictionary).with(1).arguments }
  it { should respond_to(:spell_check).with(1).arguments }
  it { should respond_to(:find).with(1).arguments }
  it { should respond_to(:try_with_regex).with(1).arguments }
  it { should respond_to(:build_regex).with(1).arguments }
  it { should respond_to(:try_with_distance).with(2).arguments }
  it { should respond_to(:show_prompt).with(0).arguments }

  let(:from) { './spec/dictionary_example' }

  before do
    ('a'..'z').each { |c| SpellChecker.dictionary[c] = [] }
  end

  after do
    ('a'..'z').each { |c| SpellChecker.dictionary[c] = [] }
  end

  describe ".initialize_dictionary" do

    it "should load dictionary into memory" do
      SpellChecker.initialize_dictionary(from)
      SpellChecker.dictionary.should eq(
        'a' => ['a'],
        'b' => [],
        'c' => [],
        'd' => [],
        'e' => [],
        'f' => [],
        'g' => [],
        'h' => ['hallowtide'],
        'i' => [],
        'j' => [],
        'k' => [],
        'l' => [],
        'm' => [],
        'n' => [],
        'o' => [],
        'p' => [],
        'q' => [],
        'r' => [],
        's' => ['shap', 'shaup', 'sheep', 'ship', 'shoop', 'shop'],
        't' => ['the'],
        'u' => [],
        'v' => [],
        'w' => [],
        'x' => [],
        'y' => [],
        'z' => ['zyzzogeton']
      )
    end

  end

  describe ".spell_check" do

    context "with unvalid argument" do

      it { SpellChecker.spell_check(nil).should eq('NO SUGGESTION') }
      it { SpellChecker.spell_check('').should eq('NO SUGGESTION') }

    end

    context "without dictionary" do

      it { SpellChecker.spell_check('foo').should eq('NO SUGGESTION') }
      it { SpellChecker.spell_check('the').should eq('NO SUGGESTION') }

    end

    context "when word is in dictionary" do

      before do
        SpellChecker.initialize_dictionary(from)
      end

      it "should only check in dictionary" do
        SpellChecker.should_receive(:find).with('the').and_return('the')
        SpellChecker.should_not_receive(:try_with_regex)
        SpellChecker.should_not_receive(:try_with_distance)
        SpellChecker.spell_check('the')
      end

    end

    context "when word is not in dictionary" do

      context "and regex search give back one candidate" do

        before do
          SpellChecker.initialize_dictionary(from)
          SpellChecker.stub(:find).and_return(nil)
        end

        it "should check with regex" do
          SpellChecker.should_receive(:try_with_regex).with('happuness').and_return('happiness')
          SpellChecker.should_not_receive(:try_with_distance)
          SpellChecker.spell_check('happuness')
        end

      end

      context "and regex search give back many candidates" do

        let(:candidates) { %w(shaup sheep shoop') }

        before do
          SpellChecker.initialize_dictionary(from)
          SpellChecker.stub(:find).and_return(nil)
          SpellChecker.stub(:try_with_regex).and_return(candidates)
        end

        it "should check with Levenshtein" do
          SpellChecker.should_receive(:try_with_distance).with('sheap', candidates).and_return('sheep')
          SpellChecker.spell_check('sheap')
        end

      end

      context "and no result showed up" do

        before do
          SpellChecker.initialize_dictionary(from)
          SpellChecker.stub(:find).and_return(nil)
          SpellChecker.stub(:try_with_regex).and_return([])
          SpellChecker.stub(:try_with_distance).and_return(nil)
        end

        it "should return 'NO SUGGESTION'" do
          SpellChecker.spell_check('abcd').should eq('NO SUGGESTION')
        end

      end

    end

  end

  describe ".find" do

    before do
      SpellChecker.initialize_dictionary(from)
    end

    it { SpellChecker.find('the').should be_true }
    it { SpellChecker.find('abcd').should be_false }

  end

  describe ".try_with_regex" do

    before do
      SpellChecker.initialize_dictionary(from)
    end

    context "when regex match" do

      let(:regex) { Regexp.new('^(?:s+h+[aeiouy]+p+)$') }

      before do
        SpellChecker.stub(:build_regex).and_return(regex)
      end

      it { SpellChecker.try_with_regex('sheeeeep').should eq(%w(shap shaup sheep ship shoop shop)) }

    end

    context "when regex does not match" do

      let(:regex) { Regexp.new('^(?:j+[aeiouy]+b+)$') }

      before do
        SpellChecker.stub(:build_regex).and_return(regex)
      end

      it { SpellChecker.try_with_regex('sheeeeep').should eq([]) }

    end

  end

  describe ".build_regex" do

    it { SpellChecker.build_regex('').is_a?(Regexp).should be_true }
    it { SpellChecker.build_regex('ssstrriuyougelate').should eq(Regexp.new('^(?:s+t+r+[aeiouy]+g+[aeiouy]+l+[aeiouy]+t+[aeiouy]+)$')) }
    it { SpellChecker.build_regex('sheeeeep').should eq(Regexp.new('^(?:s+h+[aeiouy]+p+)$')) }
    it { SpellChecker.build_regex('jjoobbb').should eq(Regexp.new('^(?:j+[aeiouy]+b+)$')) }
    it { SpellChecker.build_regex('bcd').should eq(Regexp.new('^(?:b+c+d+)$')) }

  end

  describe ".try_with_distance" do

    context "with unvalid arguments" do

      it { SpellChecker.try_with_distance('foo', []).should be_nil }

    end

    context "with valid arguments" do

      it { SpellChecker.try_with_distance('sheeeeep', %w(shap shaup sheep ship shoop shop)).should eq('sheep') }

    end

  end

end
