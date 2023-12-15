require './src/astdef'
require 'pry'

class Thunk
  attr_reader :e, :env

  def initialize(e, env)
    @e, @env = e, env
  end
end

$func_env = {}
$count = 0

def evaluate(exp, env)
  def make_thunk_list(args, env)
    return args.map {|e| Thunk.new(e, env)}
  end

  def eval_thunk(th)
    return evaluate(th.e, th.env)
  end

  def exec_fun(fn, args)
    def build_env(params, args)
      if params.length != args.length then
        begin
          raise StandardError, "Wrong number of args"
        rescue StandardError => e
          puts e.message
          exit
        end
      end
      return Environment.new(params.zip(args).to_h)
    end
    fun_def = $func_env[fn]
    new_env = build_env(fun_def.params, args)
    new_env["return"] = Thunk.new(Int.new(0), new_env)
    execute(fun_def.body, new_env)
    return eval_thunk(new_env["return"])
  end

  case exp
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
    when "<"
      return Int.new(l < r ? 1 : 0)
    when "="
      return Int.new(l == r ? 1 : 0)
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
  when Var
    return eval_thunk(env[exp.v])
  when Call
    return exec_fun(exp.fun, make_thunk_list(exp.args, env))
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
  when If
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
    env[st.v] = Thunk.new(evaluate(st.e, env), env)
    return env
  when Sequence
    for s in st.ss
      env = execute(s, env)
    end
    return env
  else
    begin
      raise StandardError, "Unknown statement " + st
    rescue StandardError => e
      puts e.message
      exit
    end
  end
end

def define_function(name, parmas, body)
  $func_env[name] = FuncDef.new(parmas, body)
end

define_function("fun1", ["i"],
  Sequence.new([Assign.new("return", Int.new(0)), 
      While.new(Var.new("i"), 
        Sequence.new([Assign.new("return", BinExp.new("+", Var.new("return"), Var.new("i"))),
        Assign.new("i", BinExp.new("-", Var.new("i"), Int.new(1)))]))]))


puts evaluate(Call.new("fun1", [Int.new(10)]), Environment.new({}))

define_function("fun2", ["i"],
  If.new(BinExp.new("<", Int.new(0), Var.new("i")),
    Assign.new("return", BinExp.new("+", Var.new("i"), Call.new("fun2", [BinExp.new("-", Var.new("i"), Int.new(1))]))),
    Assign.new("return", Int.new(0))))

puts evaluate(Call.new("fun2", [Int.new(10)]), Environment.new({}))