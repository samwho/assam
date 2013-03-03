require 'spec_helper'

describe Assam::Eflags do
  subject { Assam::Eflags.new }

  describe "setting and getting bits" do
    before do
      subject.send :set_bit, 2, true
      subject.send :set_bit, 15, true
    end

    specify("bit 2 == true")  { subject.send(:get_bit, 2).should be_true }
    specify("bit 15 == true") { subject.send(:get_bit, 15).should be_true }
  end

  describe "checking internal structure" do
    before do
      subject.send :set_bit, 8, true
    end

    its(:value) { should be 256 }
  end
end
