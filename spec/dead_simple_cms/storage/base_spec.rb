require "spec_helper"

describe DeadSimpleCMS::Storage::Base do

  include_context :sample_storage

  its(:section) { should == section }

  describe "#read" do

    specify { lambda {subject.read.should receive_error(NotImplementedError) } }

    context "when read_value is defined" do

      before(:each) do
        subject.stub(:read_value).and_return(attributes_hash_dump)
      end

      its(:read) { should == attributes_hash }

      context "and read_value is nil" do
        before(:each) do
          subject.stub(:read_value).and_return(nil)
        end

        its(:read) { should == {} }

      end
    end

    context "when @_cache is set" do
      before(:each) { subject.instance_variable_set(:@_cache, attributes_hash) }

      it "should not call #read_value" do
        subject.should_receive(:read_value).never
        subject.read
      end
    end
  end

  describe "#write" do

    it "should write_value with dump of attributes_hash" do
      subject.should_receive(:write_value).with(attributes_hash_dump)
      subject.write
    end

    it "should set the @_cache instance variable" do
      subject.stub(:write_value)
      subject.write
      subject.instance_variable_get(:@_cache).should == attributes_hash
    end

  end

  its(:unique_key) { should == :site_announcement }

end

