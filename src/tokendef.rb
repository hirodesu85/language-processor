class Token
end

class KeyWord < Token
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Number < Token
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class Identifier < Token
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class End < Token
end