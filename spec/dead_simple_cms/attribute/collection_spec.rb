require "spec_helper"

describe DeadSimpleCMS::Attribute::Collection do

  subject { described_class.new(:collection_identifier) }

  describe ".dictionary_identifier_method" do
    it "should default to :identifier" do
      described_class.dictionary_identifier_method.should == :identifier
    end
  end

  its(:identifier) { should == :collection_identifier }

  its(:attributes) { should be_an_instance_of(DeadSimpleCMS::Util::Identifier::Dictionary) }

  its (:persisted?) { should be false }

  describe "#update_attributes" do

    it "should delegate to the setter on #attributes" do
      subject.should_receive(:foo=).with(:bar)
      subject.update_attributes(:foo => :bar)
    end

  end

  describe "#add_attribute" do

    let(:string_attribute) { DeadSimpleCMS::Attribute::Type::String.new(:string_attr) }

    before(:each) do
      string_attribute.stub(:attributes_from_storage).and_return({})
      subject.add_attribute(string_attribute)
    end

    it "should create a getter method" do
      string_attribute.stub(:value).and_return("value")
      subject.string_attr.should == "value"
    end

    it "should create a setter method" do
      subject.string_attr = "value1"
      subject.attributes[:string_attr].value.should == "value1"
    end
  end

end

