require_relative "../../lib/array_scanner"

describe ArrayScanner do
  describe "#initialize" do
    it "should raise type errors for wrong arguments" do
      expect { ArrayScanner.new({}) }     .to raise_error(TypeError)
      expect { ArrayScanner.new([], nil) }.to raise_error(TypeError)
    end
  end

  before :each do
    @a = ArrayScanner.new([1,2,3,4,5])
  end

  describe "#size" do
    it "should return the arrays size" do
      @a.size.should be 5
    end
  end

  describe "#length" do
    it "is an alias for #size" do
      @a.length.should == @a.size
    end
  end

  describe "#eoa" do
    it "should return last valid position, i.d. end of array" do
      @a.eoa.should be 4
    end
  end

  describe "#eoa?" do
    it "should return false if not at end of array" do
      @a.eoa?.should be_false
    end

    it "should return true if at end of array" do
      @a.position = 4
      @a.eoa?.should be_true
    end
  end

  describe "#current_element" do
    it "should return element at the pointers position" do
      @a.position = 2
      @a.current_element.should be 3
    end
  end

  describe "#current" do
    it "is an alias for #current_element" do
      @a.position = 2
      @a.current.should be 3
    end
  end

  describe "#points_at" do
    it "is an alias for #current_element" do
      @a.position = 2
      @a.points_at.should be 3
    end
  end

  describe "#position" do
    it "should return current position" do
      @a.position.should be 0
    end
  end

  describe "#pos" do
    it "is an alias for #position" do
      @a.pos.should be 0
    end
  end

  describe "#pointer" do
    it "is an alias for #position" do
      @a.pointer.should be 0
    end
  end

  describe "#position=" do
    it "should set new position" do
      @a.position = 4
      @a.position.should be 4
    end

    it "should raise error when new position is invalid type" do
      expect { @a.position = "" }.to raise_error(TypeError)
    end

    it "should raise error when new position is outside of arrays range" do
      expect { @a.position = 6 }.to raise_error(ArgumentError)
      expect { @a.position = 5 }.to raise_error(ArgumentError)
    end

    it "should add to positions history stack" do
      [1,2,3].each { |n| @a.position = n }
      @a.pos_hist.stack.should == [2,1,0]
    end
  end

  describe "#pos=" do
    it "is an alias for #position=" do
      @a.pos = 4
      @a.position.should be 4
    end
  end

  describe "#pointer=" do
    it "is an alias for #position=" do
      @a.pointer = 4
      @a.position.should be 4
    end
  end

  describe "#surroundings" do
    it "should return element in front and element behind pointer" do
      @a.pos = 2
      @a.surroundings.should == [2,4]
    end

    it "should return nil elements for edge positions" do
      @a.surroundings.should == [nil, 2]
      @a.terminate
      @a.surroundings.should == [4, nil]
    end
  end

  describe "#last_position" do
    it "should return last position after recent movement" do
      @a.position = 1 and @a.position = 2
      @a.last_position.should be 1
    end
  end

  describe "#last_positions" do
    it "should return array of all pointer movements when called without arg" do
      @a.position = 3 and @a.position = 1 and @a.position = 4
      @a.last_positions.should == [1,3,0]
    end

    it "should return array of all pointer movements according to argument number" do
      @a.position = 3 and @a.position = 1 and @a.forward(1)
      @a.last_positions(2).should == [1,3]
    end
  end

  describe "#unscan" do
    before :each do
      [1,2,3,4].each { |n| @a.pos_hist.push(n) }
    end

    context "without argument" do
      it "should reset pointer to last position and return new value" do
        @a.unscan.should be 4
        @a.position.should be 4
      end
    end

    context "with argument" do
      it "should reset pointer by n steps and return new value" do
        @a.unscan(3).should be 2
        @a.position.should be 2
      end
    end

    it "should return nil when position history is empty" do
      @a.pos_hist.stack.clear
      @a.unscan.should be_nil
    end

  end

  describe "#last_result" do
    it "should return last result" do
      @a.scan
      @a.last_result.should == 1
    end

    it "should return last valid result with true argument" do
      @a.scan and @a.scan { |x| x == 100 }
      @a.last_result.should be_false
      @a.last_result(true).should == 1
    end
  end

  describe "#forward" do
    it "should forward pointer by argument" do
      @a.forward(2)
      @a.position.should be 2
    end

    it "should foward pointer to eoa if new position is outside of range" do
      @a.forward(10)
      @a.position.should be 4
    end
  end

  describe "#forward_to" do
    it "should forward pointer and return new position if block is true" do
      @a.forward_to { |el| el == 3 }.should be 2
      @a.position.should be 2
    end

    it "should not forward pointer and return nil if block is false" do
      @a.forward_to { |el| el == 7 }.should be_nil
      @a.position.should be 0
    end

    it "raises ArgumentError without block" do
      expect { @a.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#rewind" do
    it "should rewind pointer by argument" do
      @a.position = 3
      @a.rewind(2)
      @a.position.should be 1
    end

    it "should rewind to zero if new position is outside of range" do
      @a.position = 2
      @a.rewind(4)
      @a.position.should be 0
    end
  end

  describe "#rewind_to" do
    it "should rewind pointer to new position if block is true" do
      @a.position = 4
      @a.rewind_to { |el| el == 2 }.should be 1
      @a.position.should be 1
    end

    it "should not rewind pointer and return nil if block is false" do
      @a.position = 4
      @a.rewind_to { |el| el == 5 }.should be_nil
      @a.position.should be 4
    end

    it "raises ArgumentError without block" do
      expect { @a.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#reset" do
    it "should reset pointer to 0" do
      @a.position = 4
      @a.reset
      @a.position.should be 0
    end
  end

  describe "#terminate" do
    it "should set pointer to eoa position" do
      @a.terminate
      @a.position.should be 4
    end
  end

  describe "#clear" do
    it "is an alias for #terminate" do
      @a.clear.should be @a.terminate
    end
  end

  describe "#scanned" do
    it "should return already scanned elements" do
      @a.position = 3
      @a.scanned.should == [1,2,3]
    end
  end

  describe "#scanned_size" do
    it "should return number of scanned elements" do
      @a.position = 3
      @a.scanned_size.should be 3
    end
  end

  describe "#rest" do
    it "should return remaining elements" do
      @a.position = 1
      @a.rest.should == [2,3,4,5]
    end
  end

  describe "#rest_size" do
    it "should return number of remaining elements" do
      @a.position = 1
      @a.rest_size.should be 4
    end
  end

  describe "#scan" do
    context "without blk" do
      it "should return array element at current position and advance pointer" do
        @a.position = 2
        @a.scan.should be 3
        @a.position.should be 3
      end

      it "should not advance pointer with false argument" do
        @a.scan(false)
        @a.position.should be 0
      end

      it "should not advance pointer if at eoa" do
        @a.position = 4
        @a.scan
        @a.position.should be 4
      end
    end

    context "with blk" do
      it "should return false for false block" do
        @a.scan { |el| el == 6 }.should be_false
      end

      it "should return array element at current position for true block and advance position by 1" do
        @a.position = 2
        @a.scan { |el| el == 3 }.should be 3
        @a.position.should be 3
      end

      it "should not advance pointer with false argument" do
        @a.scan(false) { |el| el == 3 }.should be false
        @a.position.should be 0
      end
    end
  end

  describe "#scan_until" do
    it "should return array from current position to position before the block evaluated to true and move pointer" do
      @a.scan_until { |el| el == 3 }.should == [1,2]
      @a.position.should be 2
    end

    it "should return false when block is false and not move pointer." do
      @a.scan_until { |el| el == 8 }.should be_false
      @a.position.should be 0
    end

    it "should include the element for which the block evaluated true when true argument is given." do
      @a.scan_until(true) { |el| el == 3 }.should == [1,2,3]
      @a.position.should be 3
    end

    it "raises ArgumentError without block" do
      expect { @a.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#peek" do
    it "should return next element without argument" do
      @a.position = 1
      @a.peek.should == 2
    end

    it "should array of next elements by argument number" do
      @a.peek(1).should == [1]
      @a.peek(2).should == [1,2]
    end
  end

  describe "#peek_until" do
    it "should return array of next elements between current position and the element for which the block is true" do
      @a.position = 1
      @a.peek_until { |el| el == 5 }.should == [2,3,4]
    end

    it "should return empty array if block is false" do
      @a.peek_until { |el| el == 6 }.should == []
    end

    it "raises ArgumentError without block" do
      expect { @a.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#look_behind" do
    it "should return element behind pointer (i.e. pointer position - 1), when no arguemnt is given" do
      @a.pos = 2
      @a.look_behind.should be 2
    end

    it "should array of previous elements by argument number (reverse order)" do
      @a.pos = 4
      @a.look_behind(1).should == [4]
      @a.look_behind(2).should == [4,3]
    end

    it "should return nil when there is nothing behind without argument" do
      @a.look_behind.should be_nil
    end

    it "should return empty array when there is nothing behind with argument" do
      @a.look_behind(3).should == []
    end

    it "should return everything behind when argument number is larger than number of elements behind" do
      @a.pos = 2
      @a.look_behind(4).should == [2,1]
    end
  end

  describe "#look_behind_until" do
    it "should return arguemnt of previous element between current position and the element for which the block is true - in reverse order" do
      @a.pos = 4
      @a.look_behind_until { |el| el == 2 }.should == [4,3]
    end

    it "should return empty array if block is false" do
      @a.look_behind_until { |el| el == 1 }.should == []
    end

    it "raises ArgumentError without block" do
      expect { @a.look_behind_until }.to raise_error(ArgumentError)
    end
  end

  describe "#find" do
    it "should return next element after pointer for true block" do
      @a.position = 1
      @a.find { |x| x == 3 }.should be 3
    end

    it "should return nil for no find - e.g. pointer is already behind the looked up element" do
      @a.position = 3
      @a.find { |x| x == 0 }.should be_nil
    end
  end

  describe "#next" do
    it "is an alias for #find" do
      @a.position = 1
      @a.next { |x| x == 3 }.should be 3
    end
  end

  describe "#previous" do
    it "should return previous element in front of pointer for true block" do
      @a.position = 3
      @a.previous { |x| x == 2 }.should be 2
    end
  end

  describe "#rr" do
    it "should add to results history and return the argument" do
      @a.rr(1).should be 1
      @a.res_hist.stack.should == [1]
    end
  end

  describe "#to_a" do
    it "should return simple array" do
      @a.to_a.should == [1,2,3,4,5]
    end
  end

  describe "#to_s" do
    it "should return simple array to_s" do
      @a.to_s.should == "[1, 2, 3, 4, 5]"
    end
  end

  describe "#inspect" do
    it "should return pointer information" do
      @a.pos = 2
      @a.inspect.should == "Pointer at 2/4. Current element: 3"
    end
  end
end
