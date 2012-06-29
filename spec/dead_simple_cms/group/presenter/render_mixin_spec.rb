require "spec_helper"

describe DeadSimpleCMS::Group::Presenter::RenderMixin do

  subject { Class.new { include DeadSimpleCMS::Group::Presenter::RenderMixin }.new }

  shared_context :presenter_class do
    let(:presenter_class) { Class.new(DeadSimpleCMS::Group::Presenter::Base) { def render ; "render result" ; end } }
    before(:each) { subject.display(presenter_class) }
  end

  describe "#render" do
    context "when presenter_class is set" do

      include_context :presenter_class

      specify { subject.render(:view_context).should == "render result" }

    end

    context "when render_proc is set" do

      before(:each) { subject.display { |group, first, second| "#{first} #{second}" } }

      specify { subject.render(:view_context, :first_arg, :second_arg).should == "first_arg second_arg" }

      context "and when group is passed in arguments" do
        let(:group) { DeadSimpleCMS::Group.new(:group_identifier) }
        before(:each) { subject.display { |group, arg1, arg2| "#{group.identifier} #{arg1} #{arg2}" } }

        it "should use the passed in group for the render_proc" do
          subject.render([:view_context, group], "arg1", "arg2").should == "group_identifier arg1 arg2"
        end
      end

    end

    context "when group is passed in" do
      include_context :presenter_class

      it "should use that as the group" do
        presenter_class.stub(:new).with(:view_context, :group).and_return(double(:render => :result))
        subject.render([:view_context, :group])
      end

    end
  end
end

