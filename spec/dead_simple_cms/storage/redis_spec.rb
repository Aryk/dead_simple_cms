require "spec_helper"

describe DeadSimpleCMS::Storage::Redis do

  include_context :sample_storage

  specify { lambda { described_class.connection }.should raise_error NotImplementedError }
  specify { lambda { subject.send(:read_value) }.should raise_error NotImplementedError }
  specify { lambda { subject.send(:write_value, "value") }.should raise_error NotImplementedError }

  context "when Redis is defined" do
    before(:each) do
      described_class.stub(:connection).and_return(double("redis connection"))
    end

    describe "#read_value" do
      it "should read from redis" do
        described_class.connection.stub(:get).with(subject.unique_key).and_return(:result)
        subject.send(:read_value).should == :result
      end
    end

    describe "#write_value" do
      it "should write to redis" do
        described_class.connection.stub(:set).with(subject.unique_key, "value")
        subject.send(:write_value, "value")
      end

    end

  end
end

