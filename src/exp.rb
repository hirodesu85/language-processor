require './src/astdef'

# テスト用の式のデータ

$test_exp1 = BinExp.new("/", BinExp.new("*", Int.new(2), BinExp.new("-", Int.new(5), Int.new(2))), Int.new(4))

$test_exp2 = BinExp.new("*", BinExp.new("+", Int.new(1), Int.new(2)), BinExp.new("+", Int.new(3), Int.new(4)))

