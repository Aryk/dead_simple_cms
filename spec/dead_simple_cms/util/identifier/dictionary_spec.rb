require "spec_helper"

describe DeadSimpleCMS::Util::Identifier::Dictionary do

  class ClassWithIdentifier
    include DeadSimpleCMS::Util::Identifier
    alias :some_method :identifier
  end

  subject { described_class.new(ClassWithIdentifier, :identifier_method => :some_method)  }

  its(:identifier_method) { should == :some_method }
  its(:target_class) { should == ClassWithIdentifier }

  context "when items are added " do
    let(:instance_with_identifier_1) { ClassWithIdentifier.new("basketball") }
    let(:instance_with_identifier_2) { ClassWithIdentifier.new("soccer") }

    before(:each) do
      subject.add(instance_with_identifier_1)
      subject.add(instance_with_identifier_2)
    end

    its(:identifiers) { should include(:basketball, :soccer) }

    it "should be indexed by the identifier" do
      subject[:basketball].should == instance_with_identifier_1
      subject[:soccer].should == instance_with_identifier_2
    end

  end

  describe "#target_class" do

  end

  describe "#identifier_method" do

  end

  describe "#identifiers" do

  end

  describe "#add" do

  end

  describe "#include?" do

  end

  describe "#to_hash" do

  end

  describe "#[]=" do

  end

  describe "#[]" do

  end

end

