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
    result = Set.new(rx_match(rx.left, s, i).flat_map { |pos_left| rx_match(rx.right, s, pos_left) })
    return result
  when RxOr
    return rx_match(rx.left, s, i) + rx_match(rx.right, s, i)
  when RxRepeat
    next_r = Set.new([i])
    result = next_r
    while next_r.length > 0
      next_r = Set.new(next_r.flat_map { |pos| rx_match(rx.rx, s, pos) })
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
  return Set.new([])
end