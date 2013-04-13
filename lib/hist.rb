class Hist
  attr_reader :stack, :max_size

  def initialize(max_size = 10)
    @stack = []
    @max_size = max_size
  end

  def push(obj)
    @stack.pop if @stack.size == @max_size
    @stack.unshift(obj)
  end

  def recent(n = nil)
    n ? @stack.take(n) : @stack.first
  end

  def [](i)
    @stack[i]
  end
end
