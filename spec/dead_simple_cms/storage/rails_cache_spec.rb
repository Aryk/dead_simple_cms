require "spec_helper"

describe DeadSimpleCMS::Storage::RailsCache do

  include_context :sample_storage

  before(:each) do
    ::Rails.stub(:cache).and_return(double("rails cache"))
  end

  describe "#read_value" do
    it "should read from the rails cache" do
      ::Rails.cache.should_receive(:read).with(subject.unique_key)
      subject.send(:read_value)
    end
  end

  describe "#write_value" do
    it "should write to the rails cache" do
      ::Rails.cache.should_receive(:write).with(subject.unique_key, "value", kind_of(Hash))
      subject.send(:write_value, "value")
    end

    it "should set the expires_in to some time in the future" do
      ::Rails.cache.should_receive(:write).with do |key, value, options|
        options[:expires_in] > Time.now
      end
      subject.send(:write_value, "value")
    end
  end

end

