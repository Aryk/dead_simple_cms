require "spec_helper"

describe DeadSimpleCMS::Attribute::Type::Base do

  module DeadSimpleCMS
    module Attribute
      module Type
        class FakeAttribute < Base
          self.default_input_type = :string
        end
      end
    end
  end

  let(:fake_attribute_class) { DeadSimpleCMS::Attribute::Type::FakeAttribute }
  let(:group_hierarchy) do
    klass = DeadSimpleCMS::Group
    [klass.root, klass.new(:second), klass.new(:third)]
  end

  subject { fake_attribute_class.new(:fake_identifier, :label => "Fake Label", :default => 413, :hint => "some hint",
    :group_hierarchy => group_hierarchy) }

  before(:each) do
    subject.stub(:attributes_from_storage).and_return({})
  end

  describe ".builder_method_name" do
    it "should derive from the class name" do
      fake_attribute_class.builder_method_name.should == "fake_attribute"
    end
  end

  its(:label)               { should == "Fake Label" }
  its(:identifier)          { should == :fake_identifier }
  its(:default_input_type)  { should == :string }
  its(:input_type)          { should == :string }
  its(:hint)                { should == "some hint" }
  its(:required)            { should be false }
  its(:group_hierarchy)     { should == group_hierarchy }
  its(:section_identifier)  { should == :root_second_third_fake_identifier }

  describe "#label=" do
    it "should be able to set a new label" do
      subject.label = "New Label"
      subject.label.should == "New Label"
    end
  end

  describe "#root_group?" do

    its (:root_group?) { should be false }

    context "when last group is root" do
      before(:each) { subject.group_hierarchy << DeadSimpleCMS::Group.root }

      its (:root_group?) { should be true }
    end
  end
  
  describe "#default" do

    its (:default) { should == 413 }

    context "when default is passed in as a Proc" do
      before(:each) do
        delayed_value = 123
        subject.instance_variable_set(:@default, lambda { delayed_value } )
      end

      its (:default) { should == 123 }

    end
  end

  describe "#value" do

    context "when value is in attributes_from_storage" do
      before(:each) do
        subject.stub(:section_identifier).and_return(:foo)
        subject.stub(:attributes_from_storage).and_return(:foo => 3)
      end

      its(:value) { should == 3 }

      context "and value is storage is nil and default is not nil" do

        before(:each) do
          subject.stub(:default).and_return(true)
          subject.stub(:attributes_from_storage).and_return(:foo => nil)
        end

        its(:value) { should be_nil }
      end
    end

    context "when @value is not set" do
      it "should read the attribute from the storage" do
        subject.should_receive(:attributes_from_storage).and_return(subject.section_identifier => :bar)
        subject.value.should == :bar
      end

      it "should not fallback on the default if the attribute is present in the storage" do
        subject.should_receive(:attributes_from_storage).and_return(subject.section_identifier => nil)
        subject.value.should be nil
      end
    end

  end

  describe "#value=" do

    it "should convert the value" do
      subject.should_receive(:convert_value).with("value")
      subject.value = "value"
    end

  end

  describe "#convert_value" do

    it "should return nil if the value is blank" do
      subject.send(:convert_value, "").should be nil
    end

  end
  
end

