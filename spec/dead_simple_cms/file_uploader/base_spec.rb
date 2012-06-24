require "spec_helper"

describe DeadSimpleCMS::FileUploader::Base do

  let(:file_attribute) do
    DeadSimpleCMS::Attribute::Type::File.new(:image, :file_ext => "jpg").tap do |file_attribute|
      file_attribute.data = :data
    end
  end

  subject { described_class.new(file_attribute) }

  its(:file_attribute) { should == file_attribute }
  its(:file_ext) { should == file_attribute.file_ext }
  its(:data) { should == file_attribute.data }

  specify { lambda { subject.upload! }.should raise_error(NotImplementedError, "Please overwrite this with your own upload functionality.") }
  specify { lambda { subject.url }.should raise_error(NotImplementedError, "Please overwrite this with your own url constructor.") }

  describe "#path" do

    before(:each) do
      file_attribute.stub(:group_hierarchy).and_return([DeadSimpleCMS::Group.new(:foo), DeadSimpleCMS::Group.new(:bar)])
      file_attribute.stub(:section).and_return(DeadSimpleCMS::Section.new(:car))
    end

    its(:path) { should == "dead_simple_cms/car/foo/bar/image.jpg" }

    it "should remove nils when joining" do
      subject.path(nil).should == "car/foo/bar/image.jpg"
    end
  end

end

