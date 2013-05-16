require "spec_helper"

describe DeadSimpleCMS::Rails::ActionView::FragmentSweeper do
  let(:sweeper) { described_class.instance }

  describe "when fragments are given as array" do
    it "calls expire_fragment for each key" do
      sweeper.should_receive(:expire_fragment).twice
      sweeper.after_save(stub(fragments: [:test1, :test2]))
    end
  end

  describe "when cell cache should be expired" do
    let(:cell) { stub }

    it "calls expire_cell_state" do
      sweeper.should_receive(:expire_cell_state).with(cell, :main)
      sweeper.after_save(stub(fragments: [{ cell: cell, state: :main }]))
    end

    it "calls expire_cell_state for several cells" do
      sweeper.should_receive(:expire_cell_state).twice
      sweeper.after_save(stub(fragments: [{ cell: cell, state: :main },
                                          { cell: cell, state: :index }]))
    end
  end
end