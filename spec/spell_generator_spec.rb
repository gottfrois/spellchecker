# @author Pierre-Louis Gottfrois http://fr.linkedin.com/in/pierrelouisgottfrois/

require 'spell_generator'

describe SpellGenerator do

  let(:generator) { SpellGenerator.new('./spec/dictionary_example') }

  subject { generator }

  it { should respond_to(:generate).with(1).arguments }
  it { should respond_to(:dictionary) }
  it { should respond_to(:nb_word) }

  after do
    generator.dictionary = []
    generator.nb_word = 100
  end

  context "when path does not exists" do

    let(:foo) { SpellGenerator.new('') }

    subject { foo }

    it { expect { subject }.to raise_exception }

  end

  describe "#generate" do

    context "with argument" do

      it "should write on STDOUT no more than given time" do
        Kernel.should_receive(:puts).exactly(2).times
        generator.generate(2)
      end

    end

    context "without argument" do

      it "should write on STDOUT" do
        Kernel.should_receive(:puts).exactly(10).times
        generator.generate
      end

    end

    it "should print '\0' at the end" do
      Kernel.should_receive(:print).once
      generator.generate
    end

    describe "pointer to methods" do

      let(:methods) { [:upperized!, :swap_vowel!, :duplicate!] }

      context "first rand" do

        it "should call appropriate method" do
          Kernel.stub(:rand).with(3).and_return(0)
          Kernel.stub(:rand).with(2).and_return(0)
          Kernel.stub(:rand).with(15).and_return(14)
          String.any_instance.should_receive(methods[0])
          generator.generate(1)
        end

      end

      context "second rand" do

        it "should call appropriate method" do
          Kernel.stub(:rand).with(3).and_return(0)
          Kernel.stub(:rand).with(2).and_return(0)
          Kernel.stub(:rand).with(15).and_return(1)
          String.any_instance.should_receive(methods[1])
          generator.generate(1)
        end

      end

      context "when rand is out of range" do

        before do
          Kernel.stub(:rand).with(3).and_return(0)
          Kernel.stub(:rand).with(2).and_return(0)
          Kernel.stub(:rand).with(15).and_return(10)
        end

        it { expect { generator.generate }.not_to raise_exception }

      end

    end

  end

end

describe String do

  subject { '' }

  it { should respond_to(:upperized!).with(0).arguments }
  it { should respond_to(:swap_vowel!).with(0).arguments }
  it { should respond_to(:duplicate!).with(0).arguments }

  describe "#upperized!" do

    before do
      Kernel.stub(:rand).with(2).and_return(0, 1, 0)
    end

    subject { 'foo'.upperized! }

    it { should eq('FoO') }

  end

  describe "#swap_vowel!" do

    before do
      Kernel.stub(:rand).and_return(0, 4)
      Array.any_instance.stub(:shuffle).and_return(%w(a e i o u y))
    end

    subject { 'foo'.swap_vowel! }

    it { should eq('fau') }

  end

  describe "#duplicate!" do

    before do
      Kernel.stub(:rand).and_return(5, 7, 3, 4, 5, 8)
      Kernel.stub(:rand).with(2).and_return(1, 0, 1, 1, 0, 1, 0, 0, 1, 0)
    end

    subject { 'hello'.duplicate! }

    it { should eq('hheeellloo') }

  end

end
