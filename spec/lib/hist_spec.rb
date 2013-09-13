require 'spec_helper'
require 'hist'

describe Hist do
  describe "#initialize" do
    it "should come with default stack size 10" do
      Hist.new.max_size.should be 10
    end

    it "should take max sizes as argument" do
      Hist.new(11).max_size.should be 11
    end
  end

  describe "#[]" do
    it "delegates [] to stack" do
      a = Hist.new
      a.push(1) and a.push(2)
      a[1].should be 1
      a[0].should be 2
    end
  end

  describe "#push" do
    let(:hist) { Hist.new(3) }

    it "should push new element to stack" do
      hist.push(1)
      hist.stack.should == [1]
    end

    it "should not take more elements than max size" do
      hist.instance_variable_set(:@stack, [1,2,3])
      hist.push(4)
      hist.stack.should == [4,1,2]
    end
  end

  describe "#recent" do
    let(:hist) do
      h = Hist.new(3)
      h.instance_variable_set(:@stack, [1,2,3])
      h
    end

    it "should return recently added element to stack without argument" do
      hist.recent.should be 1
    end

    it "should return array of recently added elements according to argument number" do
      hist.recent(2).should == [1,2]
    end
  end
end

