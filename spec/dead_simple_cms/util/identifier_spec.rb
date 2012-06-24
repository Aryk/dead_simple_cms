require "spec_helper"

describe DeadSimpleCMS::Util::Identifier do

  before(:all) do
    IdentifierTest = Class.new do
      include DeadSimpleCMS::Util::Identifier
    end
  end

  let(:sample_class) { IdentifierTest }

  subject do
    sample_class.new("identify_me", :label => "Call me Al!")
  end

  its(:label) { should == "Call me Al!"}
  its(:identifier) { should == :identify_me }

  describe("ClassMethods") do
    subject { sample_class }

    its(:new_dictionary) { should be_an_instance_of DeadSimpleCMS::Util::Identifier::Dictionary }
  end

end

