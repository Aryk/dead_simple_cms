require "spec_helper"

describe DeadSimpleCMS::Storage::Database do

  include_context :sample_storage

  shared_context :saved_entry do
    around(:each) do |example|
      @record = described_class.active_record.create!(key: subject.unique_key, value: "value")
      example.run
      @record.destroy
    end
  end


  specify do
    described_class.active_record.should == described_class::Table
  end

  describe "#read_value" do

    include_context :saved_entry

    it "should read the record from the database" do
      subject.send(:read_value).should == "value"
    end

  end

  describe "#write_value" do
    context "when record already exists" do

      include_context :saved_entry

      it "should update the value on the record" do
        subject.send(:write_value, "value1")
        @record.reload.value.should == "value1"
      end

    end

    context "when record does not exist" do

      it "should add the entry to the database" do
        lambda { subject.send(:write_value, "value1") }.should change(described_class::Table, :count).by(1)
      end

    end
  end
end

