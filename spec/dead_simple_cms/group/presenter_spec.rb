require "spec_helper"

describe DeadSimpleCMS::Group::Presenter do

  let(:view_context) { double("view context") }
  let(:group) { DeadSimpleCMS::Group.new(:group_identifier) }
  let(:sample_presenter_class) do
    Class.new(described_class) do
      attr_reader :sample_argument
      def initialize_extra_arguments(sample_argument)
        @sample_argument = sample_argument
      end
    end
  end

  subject { sample_presenter_class.new(view_context, group, "sample argument") }

  its(:group) { should == group }

  its(:sample_argument) { should == "sample argument" }

  it "should delegate methods to the view_context" do
    view_context.stub(:some_method).and_return(:value)
    subject.some_method.should == :value
  end

end

