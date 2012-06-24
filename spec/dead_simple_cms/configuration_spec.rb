require "spec_helper"

describe DeadSimpleCMS::Configuration do

  describe "#section" do

    let(:identifier) { :some_section }

    around(:each) do |example|
      subject.section(identifier)
      example.run
      DeadSimpleCMS.sections.delete(identifier)
    end

    it "should create a helper method for the section" do
      DeadSimpleCMS.sections.should respond_to(identifier)
    end

    it "should add the section to DeadSimpleCMS.sections" do
      DeadSimpleCMS.sections.key?(identifier)
    end
  end

  describe "#group_configuration" do

    let(:identifier) { :some_group_configuration }

    around(:each) do |example|
      subject.group_configuration(identifier) { }
      example.run
      DeadSimpleCMS.group_configurations.delete(identifier)
    end

    it "shoudl add the group configuration to the DeadSimpleCMS.group_configurations" do
      DeadSimpleCMS.group_configurations.key?(identifier)
    end

  end

  describe "#register_attribute_classes" do

    let(:attribute_class) { DeadSimpleCMS::Attribute::Type::Text }

    it "should define an attribute method on the Section::Builder class" do
      DeadSimpleCMS::Section::Builder.should_receive(:define_attribute_builder_method).with(attribute_class)
      subject.register_attribute_classes(attribute_class)
    end

    it "shoudl define an attribute method on the Group::Configuration class" do
      DeadSimpleCMS::Group::Configuration.should_receive(:define_attribute_builder_method).with(attribute_class)
      subject.register_attribute_classes(attribute_class)
    end

  end

  describe "#storage_class" do

    around(:each) do |example|
      tmp = DeadSimpleCMS::Section.storage_class
      example.run
      DeadSimpleCMS::Section.storage_class = tmp
    end

    it "should set the storage class with a Symbol" do
      subject.storage_class :database
      subject.storage_class.should == DeadSimpleCMS::Storage::Database
    end

  end

  describe "#storage_serializer_class" do

    around(:each) do |example|
      tmp = DeadSimpleCMS::Storage::Base.serializer_class
      example.run
      DeadSimpleCMS::Storage::Base.serializer_class = tmp
    end

    it "should set the storage serializer" do
      subject.storage_serializer_class(:klass)
      subject.storage_serializer_class.should == :klass
    end

  end

  describe "#default_form_builder" do

    around(:each) do |example|
      tmp = DeadSimpleCMS::Rails::ActionView::Presenter.form_builder
      example.run
      DeadSimpleCMS::Rails::ActionView::Presenter.form_builder = tmp
    end

    it "should set the default form builder with a symbol" do
      subject.default_form_builder(:default)
      subject.default_form_builder.should == DeadSimpleCMS::Rails::ActionView::FormBuilders::Default
    end

  end

  describe "#file_uploader_class" do

    around(:each) do |example|
      tmp = DeadSimpleCMS::Attribute::Type::File.uploader_class
      example.run
      DeadSimpleCMS::Attribute::Type::File.uploader_class = tmp
    end

    it "should set the file uploader class" do
      subject.file_uploader_class(:klass)
      subject.file_uploader_class.should == :klass
    end

  end

end

