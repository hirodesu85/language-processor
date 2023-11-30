# 式の構文木の定義
class Expression
end

class BinExp < Expression
  attr_reader :op, :left, :right

  def initialize(op, left, right)
    @op, @left, @right = op, left, right
  end

  def to_s
    "BinExp(#{op}, #{left.to_s}, #{right.to_s})"
  end
end

class Int < Expression
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def to_s
    "Int(#{value})"
  end
end

class Var < Expression
  attr_reader :v

  def initialize(v)
    @v = v
  end
end

class Call < Expression
  attr_reader :fun, :args

  def initialize(fun, args)
    @fun = fun
    @args = args
  end
end

# 文の構文木の定義
class Statement
end

class If < Statement
  attr_reader :e, :s1, :s2

  def initialize(e, s1, s2)
    @e = e
    @s1 = s1
    @s2 = s2
  end
end

class While < Statement
  attr_reader :e, :s

  def initialize(e, s)
    @e = e
    @s = s
  end
end

class Assign < Statement
  attr_reader :v, :e

  def initialize(v, e)
    @v = v
    @e = e
  end
end

class Sequence < Statement
  attr_reader :ss

  def initialize(ss)
    @ss = ss
  end
end

class FuncDef < Statement
  attr_reader :params, :body

  def initialize(params, body)
    @params = params
    @body = body
  end
end
