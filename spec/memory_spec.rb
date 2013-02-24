require 'spec_helper'

describe Bpred::Memory do
  let(:memory) { Bpred::Memory.new(0xFF) }

  describe "Storing and loading" do
    before do
      memory.store 0x10, 1, 0xFF
      memory.store 0x20, 4, 0x00FF00FF
    end

    specify("0x00 == 0")    { memory.load(0x00, 1).should == 0 }
    specify("0x10 == 0xFF") { memory.load(0x10, 1).should == 0xFF }

    specify("0x21 == 0xFF") { memory.load(0x21, 1).should == 0xFF }
    specify("0x22 == 0x00") { memory.load(0x22, 1).should == 0x00 }
  end

  describe "Storing and loading with []" do
    before do
      memory[0x10, 1] = 0xFF
      memory[0x20, 4] = 0x00FF00FF
    end

    specify("0x00 == 0")    { memory[0x00, 1].should == 0 }
    specify("0x10 == 0xFF") { memory[0x10, 1].should == 0xFF }

    specify("0x21 == 0xFF") { memory[0x21, 1].should == 0xFF }
    specify("0x22 == 0x00") { memory[0x22, 1].should == 0x00 }
  end
end
