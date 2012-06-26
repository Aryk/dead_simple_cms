require "spec_helper"

describe DeadSimpleCMS::Section::Builder do

  include_context :sample_section

  describe "#group" do

    it "should allow for group nesting" do
      section.groups[:banners].groups[:small].should be_an_instance_of DeadSimpleCMS::Group
    end

    context "when a group_configuration is specified" do

      it "should inherit options from a group configuration" do
        section.banners.small.attributes[:url].required.should be true
        section.banners.small.attributes[:alt].default.should == "Design Beautiful Books"
      end
    end
  end

  describe "#display" do
    it "should set the presenter class on the group" do
      section.banners.small.presenter_class.should == DeadSimpleCMS::BannerPresenter
    end
  end

  describe "#extend" do
    it "should add the methods to the section" do
      section.should respond_to :test_function
    end
  end

end

