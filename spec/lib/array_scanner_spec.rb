require 'spec_helper'
require 'array_scanner'

describe ArrayScanner do
  describe "#initialize" do
    it "raises type errors for wrong arguments" do
      expect { ArrayScanner.new({}) }     .to raise_error(TypeError)
      expect { ArrayScanner.new([], nil) }.to raise_error(TypeError)
    end
  end

  let(:as) { ArrayScanner.new([1,2,3,4,5]) }

  describe "#size" do
    it "returns the arrays size" do
      as.size.should be 5
    end
  end

  describe "#length" do
    it "is an alias for #size" do
      as.length.should == as.size
    end
  end

  describe "#eoa" do
    it "returns last valid position, i.d. end of array" do
      as.eoa.should be 4
    end
  end

  describe "#eoa?" do
    it "returns false if not at end of array" do
      as.eoa?.should be_false
    end

    it "returns true if at end of array" do
      as.position = 4
      as.eoa?.should be_true
    end
  end

  describe "#current_element" do
    it "returns element at the pointers position" do
      as.position = 2
      as.current_element.should be 3
    end
  end

  describe "#current" do
    it "is an alias for #current_element" do
      as.position = 2
      as.current.should be 3
    end
  end

  describe "#points_at" do
    it "is an alias for #current_element" do
      as.position = 2
      as.points_at.should be 3
    end
  end

  describe "#position" do
    it "returns current position" do
      as.position.should be 0
    end
  end

  describe "#pos" do
    it "is an alias for #position" do
      as.pos.should be 0
    end
  end

  describe "#pointer" do
    it "is an alias for #position" do
      as.pointer.should be 0
    end
  end

  describe "#position=" do
    it "sets new position" do
      as.position = 4
      as.position.should be 4
    end

    it "raises error when new position is invalid type" do
      expect { as.position = "" }.to raise_error(TypeError)
    end

    it "raises error when new position is outside of arrays range" do
      expect { as.position = 6 }.to raise_error(ArgumentError)
      expect { as.position = 5 }.to raise_error(ArgumentError)
    end

    it "adds to positions history stack" do
      [1,2,3].each { |n| as.position = n }
      as.pos_hist.stack.should == [2,1,0]
    end
  end

  describe "#pos=" do
    it "is an alias for #position=" do
      as.pos = 4
      as.position.should be 4
    end
  end

  describe "#pointer=" do
    it "is an alias for #position=" do
      as.pointer = 4
      as.position.should be 4
    end
  end

  describe "#surroundings" do
    it "returns element in front and element behind pointer" do
      as.pos = 2
      as.surroundings.should == [2,4]
    end

    it "returns nil elements for edge positions" do
      as.surroundings.should == [nil, 2]
      as.terminate
      as.surroundings.should == [4, nil]
    end
  end

  describe "#last_position" do
    it "returns last position after recent movement" do
      as.position = 1 and as.position = 2
      as.last_position.should be 1
    end
  end

  describe "#last_positions" do
    it "returns array of all pointer movements when called without arg" do
      as.position = 3 and as.position = 1 and as.position = 4
      as.last_positions.should == [1,3,0]
    end

    it "returns array of all pointer movements according to argument number" do
      as.position = 3 and as.position = 1 and as.forward(1)
      as.last_positions(2).should == [1,3]
    end
  end

  describe "#unscan" do
    before :each do
      [1,2,3,4].each { |n| as.pos_hist.push(n) }
    end

    context "without argument" do
      it "resets pointer to last position and return new value" do
        as.unscan.should be 4
        as.position.should be 4
      end
    end

    context "with argument" do
      it "resets pointer by n steps and return new value" do
        as.unscan(3).should be 2
        as.position.should be 2
      end
    end

    it "returns nil when position history is empty" do
      as.pos_hist.stack.clear
      as.unscan.should be_nil
    end

  end

  describe "#last_result" do
    it "returns last result" do
      as.scan
      as.last_result.should == 1
    end

    it "returns last valid result with true argument" do
      as.scan and as.scan { |x| x == 100 }
      as.last_result.should be_false
      as.last_result(true).should == 1
    end
  end

  describe "#last_results" do
    it "returns an array of latest scan results (latest is first element)" do
      as.scan and as.scan
      as.last_results.should == [2, 1]
    end

    it "returns n last results when called with argument n" do
      as.scan and as.scan
      as.last_results(1).should == [2]
    end

  end

  describe "#forward" do
    it "forwards pointer by argument" do
      as.forward(2)
      as.position.should be 2
    end

    it "fowards pointer to eoa if new position is outside of range" do
      as.forward(10)
      as.position.should be 4
    end
  end

  describe "#forward_to" do
    it "forwards pointer and return new position if block is true" do
      as.forward_to { |el| el == 3 }.should be 2
      as.position.should be 2
    end

    it "does not forward pointer and return nil if block is false" do
      as.forward_to { |el| el == 7 }.should be_nil
      as.position.should be 0
    end

    it "raises ArgumentError without block" do
      expect { as.forward_to }.to raise_error(ArgumentError)
    end
  end

  describe "#rewind" do
    it "rewinds pointer by argument" do
      as.position = 3
      as.rewind(2)
      as.position.should be 1
    end

    it "rewinds to zero if new position is outside of range" do
      as.position = 2
      as.rewind(4)
      as.position.should be 0
    end
  end

  describe "#rewind_to" do
    it "rewinds pointer to new position if block is true" do
      as.position = 4
      as.rewind_to { |el| el == 2 }.should be 1
      as.position.should be 1
    end

    it "does not rewind pointer and return nil if block is false" do
      as.position = 4
      as.rewind_to { |el| el == 5 }.should be_nil
      as.position.should be 4
    end

    it "raises ArgumentError without block" do
      expect { as.rewind_to }.to raise_error(ArgumentError)
    end
  end

  describe "#reset" do
    it "resets pointer to 0" do
      as.position = 4
      as.reset
      as.position.should be 0
    end
  end

  describe "#terminate" do
    it "sets pointer to eoa position" do
      as.terminate
      as.position.should be 4
    end
  end

  describe "#clear" do
    it "is an alias for #terminate" do
      as.clear.should be as.terminate
    end
  end

  describe "#scanned" do
    it "returns already scanned elements" do
      as.position = 3
      as.scanned.should == [1,2,3]
    end
  end

  describe "#scanned_size" do
    it "returns number of scanned elements" do
      as.position = 3
      as.scanned_size.should be 3
    end
  end

  describe "#rest" do
    it "returns remaining elements" do
      as.position = 1
      as.rest.should == [2,3,4,5]
    end
  end

  describe "#rest_size" do
    it "returns number of remaining elements" do
      as.position = 1
      as.rest_size.should be 4
    end
  end

  describe "#scan" do
    context "without blk" do
      it "returns array element at current position and advance pointer" do
        as.position = 2
        as.scan.should be 3
        as.position.should be 3
      end

      it "does not advance pointer with false argument" do
        as.scan(false)
        as.position.should be 0
      end

      it "does not advance pointer if at eoa" do
        as.position = 4
        as.scan
        as.position.should be 4
      end
    end

    context "with blk" do
      it "returns false for false block" do
        as.scan { |el| el == 6 }.should be_false
      end

      it "returns array element at current position for true block and advance position by 1" do
        as.position = 2
        as.scan { |el| el == 3 }.should be 3
        as.position.should be 3
      end

      it "does not advance pointer with false argument" do
        as.scan(false) { |el| el == 3 }.should be false
        as.position.should be 0
      end
    end
  end

  describe "#scan_until" do
    it "returns array from current position to position before the block evaluated to true and move pointer" do
      as.scan_until { |el| el == 3 }.should == [1,2]
      as.position.should be 2
    end

    it "returns false when block is false and not move pointer." do
      as.scan_until { |el| el == 8 }.should be_false
      as.position.should be 0
    end

    it "includes the element for which the block evaluated true when true argument is given." do
      as.scan_until(true) { |el| el == 3 }.should == [1,2,3]
      as.position.should be 3
    end

    it "rests pointer at eoa when true argument is given and the truthy result is at eoa." do
      as.scan_until(true) { |el| el == 5 }.should == [1,2,3,4,5]
      as.position.should == as.eoa
    end

    it "raises ArgumentError without block" do
      expect { as.scan_until }.to raise_error(ArgumentError)
    end
  end

  describe "#peek" do
    it "returns next element without argument" do
      as.position = 1
      as.peek.should == 2
    end

    it "arrays of next elements by argument number" do
      as.peek(1).should == [1]
      as.peek(2).should == [1,2]
    end
  end

  describe "#peek_until" do
    it "returns array of next elements between current position and the element for which the block is true" do
      as.position = 1
      as.peek_until { |el| el == 5 }.should == [2,3,4]
    end

    it "returns empty array if block is false" do
      as.peek_until { |el| el == 6 }.should == []
    end

    it "raises ArgumentError without block" do
      expect { as.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#look_behind" do
    it "returns element behind pointer (i.e. pointer position - 1), when no arguemnt is given" do
      as.pos = 2
      as.look_behind.should be 2
    end

    it "arrays of previous elements by argument number (reverse order)" do
      as.pos = 4
      as.look_behind(1).should == [4]
      as.look_behind(2).should == [4,3]
    end

    it "returns nil when there is nothing behind without argument" do
      as.look_behind.should be_nil
    end

    it "returns empty array when there is nothing behind with argument" do
      as.look_behind(3).should == []
    end

    it "returns everything behind when argument number is larger than number of elements behind" do
      as.pos = 2
      as.look_behind(4).should == [2,1]
    end
  end

  describe "#look_behind_until" do
    it "returns arguemnt of previous element between current position and the element for which the block is true - in reverse order" do
      as.pos = 4
      as.look_behind_until { |el| el == 2 }.should == [4,3]
    end

    it "returns empty array if block is false" do
      as.look_behind_until { |el| el == 1 }.should == []
    end

    it "raises ArgumentError without block" do
      expect { as.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#find" do
    it "returns next element after pointer for true block" do
      as.position = 1
      as.find { |x| x == 3 }.should be 3
    end

    it "returns nil for no find - e.g. pointer is already behind the looked up element" do
      as.position = 3
      as.find { |x| x == 0 }.should be_nil
    end

    it "raises ArgumentError without block" do
      expect { as.find }.to raise_error(ArgumentError)
    end
  end

  describe "#next" do
    it "is an alias for #find" do
      as.position = 1
      as.next { |x| x == 3 }.should be 3
    end
  end

  describe "#previous" do
    it "returns previous element in front of pointer for true block" do
      as.position = 3
      as.previous { |x| x == 2 }.should be 2
    end

    it "raises ArgumentError without block" do
      expect { as.previous }.to raise_error(ArgumentError)
    end
  end

  describe "#rr" do
    it "adds to results history and return the argument" do
      as.rr(1).should be 1
      as.res_hist.stack.should == [1]
    end
  end

  describe "#to_a" do
    it "returns simple array" do
      as.to_a.should == [1,2,3,4,5]
    end
  end

  describe "#to_s" do
    it "returns simple array to_s" do
      as.to_s.should == "[1, 2, 3, 4, 5]"
    end
  end

  describe "#inspect" do
    it "returns pointer information" do
      as.pos = 2
      as.inspect.should == "Pointer at 2/4. Current element: 3"
    end
  end
end
