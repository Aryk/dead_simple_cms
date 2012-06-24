require "spec_helper"

shared_examples_for DeadSimpleCMS::Attribute::Type::CollectionSupport do
  describe "#initialize" do
    context "when collection is provided" do

      let(:options) { {} }

      subject { described_class.new(:some_identifier, options.update(:collection => %w{a b c})) }

      context "and valid :input_type is specified" do
        let(:options) { {:input_type => :radio} }
        its(:input_type) { should == :radio }
      end

      context "and valid :input_type is not specified" do
        let(:options) { {:input_type => :string} }

        def self.default_input_type(type)
          around(:each) do |example|
            tmp = described_class.default_input_type
            described_class.default_input_type = type
            example.run
            described_class.default_input_type = tmp
          end
        end

        context "and default_input_type is not valid" do
          default_input_type(:string)
          its(:input_type) { should == described_class::DEFAULT_COLLECTION_INPUT_TYPE }
        end

        context "and default_input_type is valid" do
          default_input_type(:radio)
          its(:input_type) { should == :radio }
        end

      end

    end
  end
end
shared_context "Attribute Setup" do

  let(:options) { {} }

  subject { described_class.new(:sample_identifier, options) }

end
describe DeadSimpleCMS::Attribute::Type::String do

  include_context "Attribute Setup"

  it_behaves_like DeadSimpleCMS::Attribute::Type::CollectionSupport

  its(:default_input_type) { should == :string }

end
describe DeadSimpleCMS::Attribute::Type::Text do

  include_context "Attribute Setup"

  its(:default_input_type) { should == :text }

end
describe DeadSimpleCMS::Attribute::Type::Symbol do

  include_context "Attribute Setup"

  its(:default_input_type) { should == :string }

end
describe DeadSimpleCMS::Attribute::Type::Boolean do

  include_context "Attribute Setup"

  it_behaves_like DeadSimpleCMS::Attribute::Type::CollectionSupport

  its(:default_input_type) { should == :radio }
  its(:collection) { should == [true, false] }

  describe "#convert_value" do
    it %{should convert "true" or "1" into TrueClass} do
      ["True", "true", "1", "TruE"].each do |str|
        subject.send(:convert_value, str).should be true
      end
    end

    it %{should interpret everything else as false} do
      %w{abcs false 0 dude sweet}.each do |str|
        subject.send(:convert_value, str).should be false
      end
    end

    context "when a non-String is passed in" do
      it "should interpret true or false as themselves" do
        [true, false].each do |bool|
          subject.send(:convert_value, bool).should be bool
        end
      end

      it "should interpret nil as false" do
        subject.send(:convert_value, nil).should be false
      end

      it "should interpret other objects" do
        [Object.new, :dfdf].each { |x| subject.send(:convert_value, x).should be true }
      end

    end
  end
end
describe DeadSimpleCMS::Attribute::Type::Numeric do

  include_context "Attribute Setup"

  it_behaves_like DeadSimpleCMS::Attribute::Type::CollectionSupport

  its(:default_input_type) { should == :string }

end
describe DeadSimpleCMS::Attribute::Type::Integer do

  include_context "Attribute Setup"

  it_behaves_like DeadSimpleCMS::Attribute::Type::CollectionSupport

  its(:default_input_type) { should == :string }

  describe "#convert_value" do
    it "should convert the value into an integer" do
      subject.send(:convert_value, "545").should be 545
    end

    it "should return nil if nil passed in" do
      subject.send(:convert_value, nil).should be nil
    end

  end

end
describe DeadSimpleCMS::Attribute::Type::File do

  include_context "Attribute Setup"

  its(:default_input_type) { should == :file }

  let(:file_ext) { "jpg" }
  let(:data) { double("data") }
  let(:options) { {:data => data, :file_ext => file_ext}}
  let(:uploaded_file) do
    require 'stringio'
    ActionDispatch::Http::UploadedFile.new(:filename => "filename.png", :tempfile => StringIO.new("file information") )
  end

  its(:data) { should == data }

  describe "#file_ext" do
    its(:file_ext) { should == file_ext }

    it "should default to 'dat' if none provided" do
      described_class.new(:identifier).file_ext.should == "dat"
    end
  end

  describe "#convert_value" do
    it "should return the value if it is a String" do
      subject.send(:convert_value, "string").should == "string"
    end

    it "should return the value if it is nil" do
      subject.send(:convert_value, nil).should be nil
    end

    context "when ActionDispatch::Http::UploadedFile is passed in" do
      it "should set the file_ext from the uploaded filename" do
        subject.send(:convert_value, uploaded_file)
        subject.file_ext.should == "png"
      end

      it "should set the data" do
        subject.send(:convert_value, uploaded_file)
        subject.data.should == "file information"
      end

      it "should return the stored @value" do
        subject.instance_variable_set(:@value, :value)
        subject.send(:convert_value, uploaded_file).should == :value
      end
    end
  end

  describe "#upload!" do

    context "when uploader_class is not set" do
      around(:each) do |example|
        tmp = described_class.uploader_class
        described_class.uploader_class = nil
        example.run
        described_class.uploader_class = tmp
      end

      it "should raise an error if the uploader_class is not set" do
        lambda { subject.upload! }.should raise_error(NotImplementedError)
      end

    end

    context "when uploader_class is set" do
      let(:file_uploader_class) do
        Class.new(DeadSimpleCMS::FileUploader::Base) do
          def upload! ; end
          def url; "new url" end
        end
      end

      before(:each) do
        subject.uploader_class = file_uploader_class
      end
      it "should call upload!" do
        subject.should_receive(:upload!).once
        subject.upload!
      end

      it "should set the url with the value" do
        subject.upload!
        subject.value.should == "new url"
      end

    end
  end

end

describe DeadSimpleCMS::Attribute::Type::Image do

  include_context "Attribute Setup"

  let(:options) { {:width => 406, :height => 600} }

  its(:width) { should == 406 }
  its(:height) { should == 600 }

  describe "#hint" do
    context "when not set" do
      its(:hint) { should == "Image should be 406 x 600." }
    end
  end

end


