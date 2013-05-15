require "spec_helper"

describe DeadSimpleCMS::Section do

  subject do
    described_class.new(:section_identifier, :path => "/path" )
  end

  its(:path) { should == "/path" }

  describe "#root_group" do
    it "should add the root group on initialize" do
      section = described_class.new(:section_identifier)
      section.root_group.should be_an_instance_of DeadSimpleCMS::Group
    end
  end

  describe "#to_param" do
    it "should delegate to the storage" do
      subject.storage.should_receive(:to_param).and_return(:result)
      subject.to_param.should == :result
    end
  end

  describe "#add_attribute" do
    let(:attribute) { DeadSimpleCMS::Attribute::Type::String.new(:attribute_identifier) }
    before(:each) { subject.add_attribute(attribute) }

    it "should set the section on the attribute" do
      attribute.section.should == subject
    end

    context "when attribute is top level" do
      before(:each) { attribute.stub(:root?).and_return(true) }

      it "should have alias with just the attribute identfier" do
        subject.should respond_to :attribute_identifier
        subject.should respond_to :"attribute_identifier="
      end
    end
  end

  describe "#fragments" do
    context "when some fragments are proc" do
      before(:each) do
        subject.instance_variable_set(:@fragments, [lambda { |x| "hi there" }, 1234])
      end

      its(:fragments) { should == ["hi there", 1234] }
    end

  end

  describe "#storage" do
    specify { subject.storage.should be_a DeadSimpleCMS::Storage::Base }
  end

  describe "#refresh!" do
    before(:each) do
      subject.instance_variable_set(:@storage, :some_value)
      subject.refresh!
    end

    specify { subject.instance_variable_get(:@storage).should be_nil }
  end

  describe "#cache_key" do
    before do
      subject.build { string :string_attribute }
    end

    its(:cache_key) { should == "cms/section_identifier/8d0f9ad6dab42d30d259ebd656b4d5ae" }

    it "changes when value is changed" do
      expect {
        subject.update_attributes(:string_attribute => "value")
      }.to change(subject, :cache_key)
    end
  end

  describe "#update_attributes" do
    before(:each) do
      subject.build do
        string :string_attribute
        group(:level1) do
          string :another_string
        end
      end
    end

    specify do
      subject.should_receive(:save!)
      subject.update_attributes(:string_attribute => "value", :level1_another_string => "value1")
    end

  end

  describe "#save!" do
    it "should call upload_file_attributes before save" do
      subject.should_receive(:upload_file_attributes).once
      subject.save!
    end
  end

end

