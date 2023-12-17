require 'set'
require 'pry'

class Reg
end

class RxChar < Reg
  attr_reader :ch

  def initialize(ch)
    @ch = ch
  end
end

class RxAny < Reg
end

class RxEmpty < Reg
end

class RxSeq < Reg
  attr_reader :left, :right

  def initialize(left, right)
    @left, @right = left, right
  end
end

class RxOr < Reg
  attr_reader :left, :right

  def initialize(left, right)
    @left, @right = left, right
  end
end

class RxRepeat < Reg
  attr_reader :rx

  def initialize(rx)
    @rx = rx
  end
end

def rx_match(rx, s, i)
  case rx
  when RxChar
    if i < s.length && rx.ch == s[i]
      return Set.new([i + 1])
    end
  when RxAny
    if i < s.length
      return Set.new([i + 1])
    end
  when RxEmpty
    if i <= s.length
      return Set.new([i])
    end
  when RxSeq
    result = Set.new(rx_match(rx.left, s, i).map { |pos_left| rx_match(rx.right, s, pos_left) }).flatten
    return result
  when RxOr
    return rx_match(rx.left, s, i) + rx_match(rx.right, s, i)
  when RxRepeat
    next_r = Set.new([i])
    result = next_r
    while next_r.length > 0
      next_r = Set.new(next_r.map { |pos| rx_match(rx.rx, s, pos) }).flatten
      result = result + next_r
    end
    return result
  else
    begin
      raise StandardError, "Unknown rx "
    rescue StandardError => e
      puts e.message
      exit
    end
  end
  return Set.new
end


# rx1 = RxSeq.new(RxRepeat.new(RxChar.new('a')), RxChar.new('a'))
# p rx_match(rx1, 'aaa', 0)

rx2 = RxSeq.new(RxOr.new(RxChar.new('a'), RxEmpty.new), RxChar.new('b'))
p rx_match(rx2, 'b', 0)