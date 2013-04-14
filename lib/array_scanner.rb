require "array_scanner/version"
require_relative "hist"

class ArrayScanner
  attr_reader :position, :pos_hist, :res_hist
  alias :pos     :position
  alias :pointer :position

  def initialize(arr, history_size = 10)
    raise TypeError.new("Argument is not an Array.")      unless arr.is_a?(Array)
    raise TypeError.new("History size is not a Fixnum.")  unless history_size.is_a?(Fixnum)

    @arr = arr
    @position = 0

    @pos_hist = Hist.new(history_size)
    @res_hist = Hist.new(history_size)
  end

  def size
    @arr.size
  end

  alias :length :size

  def eoa
    size - 1
  end

  def eoa?
    @position == eoa
  end

  def current_element
    @arr[@position]
  end

  alias :points_at :current_element
  alias :current   :current_element

  def position=(new)
    raise TypeError.new("New position not a Fixnum.") unless new.is_a? Fixnum
    raise ArgumentError.new("New position #{new} outside of range 0..#{eoa}.") unless new.between?(0, eoa)

    @pos_hist.push(@position)
    @position = new
  end

  alias :pos=     :position=
  alias :pointer= :position=

  def surroundings
    [scanned.last, rest[1]]
  end

  def last_position
    @pos_hist.recent
  end

  def last_positions(n = nil)
    n ? @pos_hist.recent(n) : @pos_hist.stack
  end

  def unscan(steps = 1)
    return nil if last_positions.empty?
    self.position = last_positions[steps - 1] || last_positions.last
  end

  def last_result(valid = false)
    valid ? @res_hist.stack.find { |x| x } : @res_hist.recent
  end

  def last_results(n = nil)
    n ? @res_hist.recent(n) : @res_hist.stack
  end

  def forward(fixnum)
    new = @position + fixnum
    self.position = (new > eoa ? eoa : new)
  end

  def forward_to
    if block_given?
      f = rest.find { |x| yield(x) }
      f ? self.position = @arr.index(f) : nil
    else
      raise needs_block
    end
  end

  def rewind(fixnum)
    new = @position - fixnum
    self.position = (new < 0 ? 0 : new)
  end

  def rewind_to
    if block_given?
      b = scanned.find { |x| yield(x) }
      b ? self.position = @arr.index(b) : nil
    else
      raise needs_block
    end
  end

  def reset
    self.position = 0
  end

  def terminate
    self.position = eoa
  end

  alias :clear :terminate

  def scanned
    @arr[0...@position]
  end

  def scanned_size
    @position
  end

  def rest
    @arr[@position..-1]
  end

  def rest_size
    size - @position
  end

  def scan(forward = true)
    res = @arr[@position]

    if block_given? and not yield(res)
      rr(false)
    else
      forward(1) if forward &! eoa?
      rr(res)
    end
  end

  def scan_until(include_true_element = false)
    if block_given?
      if e = rest.find { |el| yield(el) }
        i  = @arr.index(e)
        i += 1 if include_true_element

        self.position = (i > eoa ? eoa : i)
        rr(@arr[last_position...i])
      else
        rr(false)
      end
    else
      raise needs_block
    end
  end

  def peek(n = nil)
    n ? rest.take(n) : rest.first
  end

  def peek_until
    if block_given?
      i = rest.index { |el| yield(el) }
      i ? rest[0...i] : []
    else
      raise needs_block
    end
  end

  def look_behind(n = nil)
    n ? scanned.reverse.take(n) : scanned.last
  end

  def look_behind_until
    if block_given?
      rev = scanned.reverse
      i = rev.index { |el| yield(el) }
      i ? rev[0...i] : []
    else
      raise needs_block
    end
  end

  def find
    if block_given?
      rest.find { |e| yield e }
    else
      raise needs_block
    end
  end

  alias :next :find

  def previous
    if block_given?
      scanned.reverse.find { |e| yield e }
    else
      raise needs_block
    end
  end

  def rr(obj)
    # means return result
    @res_hist.push(obj)
    obj
  end

  def needs_block
    ArgumentError.new("Method needs block.")
  end

  def to_a
    @arr
  end

  def to_s
    @arr.to_s
  end

  def inspect
    "Pointer at #{@position}/#{eoa}. Current element: #{":" if current.is_a?(Symbol)}#{current}"
  end
end
