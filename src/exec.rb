require './src/astdef'
require './src/exp'

def evaluate(exp, env)
  case exp
  when Var
    return env[exp.v]
  when BinExp
    l = evaluate(exp.left, env).value
    r = evaluate(exp.right, env).value
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
    return Int.new(exp.value)
  else
    begin
      raise StandardError, "Unknown expression " + exp
    rescue StandardError => e
      puts e.message
      exit
    end
  end
end

def execute(st, env)
  case st
  when  If
    if evaluate(st.e, env).value != 0
      return execute(st.s1, env)
    else
      return execute(st.s2, env)
    end
  when While
    while evaluate(st.e, env).value != 0
      env = execute(st.s, env)
    end
    return env
  when Assign
    value = evaluate(st.e, env)
    env[st.v] = value
    return env
  when Sequence
    for s in st.ss
      env = execute(s, env)
    end
    return env
  end
end

test_st1 = While.new(Var.new('i'), Assign.new('i', BinExp.new('-', Var.new('i'), Int.new(1))))

test_st2 = Sequence.new([Assign.new('i', Int.new(10)), Assign.new('sum', Int.new(0)), While.new(Var.new('i'), Sequence.new([Assign.new('sum', BinExp.new('+', Var.new('sum'), Var.new('i'))), Assign.new('i', BinExp.new('-', Var.new('i'), Int.new(1)))]))])

# puts execute(test_st1, Environment.new({'i' => Int.new(10)})).to_s

puts execute(test_st2, Environment.new({})).to_s