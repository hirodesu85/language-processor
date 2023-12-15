class Regexp
end

class RxChar < Regexp
  attr_reader :ch

  def initialize(ch)
    @ch = ch
  end
end

class RxAny < Regexp
end

class RxEmpty < Regexp
end

class RxSeq < Regexp
  attr_reader :left, :right

  def initialize(left, right)
    @left, @right = left, right
  end
end

class RxOr < Regexp
  attr_reader :left, :right

  def initialize(left, right)
    @left, @right = left, right
  end
end

class RxRepeat < Regexp
  attr_reader :rx

  def initialize(rx)
    @rx = rx
  end
end