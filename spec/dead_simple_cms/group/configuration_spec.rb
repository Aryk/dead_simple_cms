require "spec_helper"

describe DeadSimpleCMS::Group::Configuration do

  let(:options) { {} }

  subject do
    described_class.new(:group_configuration_identifier, options) do
      string :string_var, :default => true
    end
  end

  include_examples :group_display

  its(:identifier) { should == :group_configuration_identifier }

  describe ".define_attribute_builder_method" do

    it "should add to the attribute_arguments" do
      subject.attribute_arguments[:string_var].should == ["string", {:default => true}]
    end

  end

end