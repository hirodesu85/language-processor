require './src/astdef'
require './src/exp'

def apply_rule(exp) 
  # 1ステップの遷移を行う
  if exp.left.class == Int && exp.right.class == Int then
    # 両辺とも数値
    case exp.op
    when "+"
      return Int.new(exp.left.value + exp.right.value)
    when "-"
      return Int.new(exp.left.value - exp.right.value)
    when "*"
      return Int.new(exp.left.value * exp.right.value)
    when "/"
      return Int.new(exp.left.value / exp.right.value)
    else
      begin
        raise StandardError, "Unknown op " + op
      rescue StandardError => e
        puts e.message
        exit
      end
    end
  elsif exp.left.class == BinExp then
    # 左辺が数値でない
    return BinExp.new(exp.op, apply_rule(exp.left), exp.right)
  elsif exp.right.class == BinExp then
    # 右辺が数値でない
    return BinExp.new(exp.op, exp.left, apply_rule(exp.right))
  else
    begin
      raise StandardError, "No applicable rule"
    rescue StandardError => e
      puts e.message
      exit
    end
  end
end

def rewrite_loop(exp)
  # 終了状態（全体が数値）になるまで遷移を繰り返す
  while !(exp.class == Int)
    puts exp.to_s
    exp = apply_rule(exp)
  end
  return exp
end

puts rewrite_loop($test_exp2)