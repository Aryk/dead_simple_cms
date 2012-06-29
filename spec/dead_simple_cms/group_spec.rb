require "spec_helper"

describe DeadSimpleCMS::Group do

  let(:options) { {} }
  subject { described_class.new(:group_identifier, options) }

  its(:identifier) { should == :group_identifier }
  its(:groups) { should be_an_instance_of DeadSimpleCMS::Util::Identifier::Dictionary }

  include_examples :group_display

  describe ".root" do
    specify { described_class.root.should be_an_instance_of described_class }
  end
  
  describe "#root?" do

    its(:root?) { should be false }

    context "when identifier is ROOT_IDENTIFIER" do
      subject { described_class.new(described_class::ROOT_IDENTIFIER) }
      its(:root?) { should be true }
    end

  end
  
  describe "#add_group" do

    let(:nested_group) { described_class.new(:nested_group) }
    before(:each) { subject.add_group(nested_group) }

    it "should add the group to the #groups" do
      subject.groups.keys.should include(:nested_group)
    end

    it "should create a group reader and return it" do
      subject.nested_group.should == nested_group
    end

    it "should create an _attributes= writer" do
      nested_group.should_receive(:update_attributes).with(:value)
      subject.nested_group_attributes = :value
    end

    it "should set the parent" do
      nested_group.parent.should == subject
    end

  end
  
end

