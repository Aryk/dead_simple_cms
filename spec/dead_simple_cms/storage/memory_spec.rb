require "spec_helper"

describe DeadSimpleCMS::Storage::Memory do

  include_context :sample_storage

  let(:attributes_hash) { {:foo => 1, :bar => 2} }
  subject { described_class.new(section) }

  after(:each) do
    described_class.class_variable_set(:@@cache, {})
  end

  it "should return value from @@cache" do
    subject.send(:read_value)
  end

  it "should write value to @@cache" do
    subject.send(:write_value, "value")
    described_class.class_variable_get(:@@cache).should == {:site_announcement => "value"}
  end


end

