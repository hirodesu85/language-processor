require './src/astdef'

$func_env = {}

def evaluate(exp, env)
  # 式のリストを評価して、値のリストにする
  def evaluate_list(args, env)
    return args.map { |e| evaluate(e, env)}
  end

  # 関数名と実引数の値のリストを与えて関数を実行し、結果の値を返す
  def exec_fun(fn, args)
    # 引数（変数）名のリストと、対応する値のリストから、環境を作る
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
    new_env.env["return"] = Int.new(0)
    execute(fun_def.body, new_env)
    return new_env["return"]
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
    return env[exp.v]
  when Call
    return exec_fun(exp.fun, evaluate_list(exp.args, env))
  else
    begin
      raise StandardError, "Unknown expression " + exp.to_s
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
    value = evaluate(st.e, env)
    env[st.v] = value
    return env
  when Sequence
    for s in st.ss
      env = execute(s, env)
    end
    return env
  else
    begin
      raise StandardError, "Unknown statement " + st.to_s
    rescue StandardError => e
      puts e.message
      exit
    end
  end
end

def define_function(name, params, body)
  $func_env[name] = FuncDef.new(params, body)
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