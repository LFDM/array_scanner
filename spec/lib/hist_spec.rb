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
    before :each do
      @a = Hist.new(3)
    end

    it "should push new element to stack" do
      @a.push(1)
      @a.stack.should == [1]
    end

    it "should not take more elements than max size" do
      @a.instance_variable_set(:@stack, [1,2,3])
      @a.push(4)
      @a.stack.should == [4,1,2]
    end
  end

  describe "#recent" do
    before :each do
      @a = Hist.new(3)
      @a.instance_variable_set(:@stack, [1,2,3])
    end

    it "should return recently added element to stack without argument" do
      @a.recent.should be 1
    end

    it "should return array of recently added elements according to argument number" do
      @a.recent(2).should == [1,2]
    end
  end
end

