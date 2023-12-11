require './src/astdef'
require './src/exp'

def eval_const(exp)
  case exp
  when BinExp
    l = eval_const(exp.left).value
    r = eval_const(exp.right).value
    case exp.op
    when "+"
      return Int.new(l + r)
    when "-" 
      return Int.new(l - r)
    when "*"  
      return Int.new(l * r)
    when "/"
      return Int.new(l / r)
    else
      begin
        raise StandardError, "Unknown op " + op
      rescue StandardError => e
        puts e.message
        exit
      end
    end
  when Int
    return exp
  else
    begin
      raise StandardError, "Unknown expression " + op
    rescue StandardError => e
      puts e.message
      exit
    end
  end
end

# test
puts eval_const($test_exp2).to_s