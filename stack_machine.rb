def execute(code, stack)
  while code.length > 0 do
    puts "(#{code}, #{stack})"
    op = code.shift
    if op == "Push" then
      operand = code.shift
      stack.push(operand)
    elsif op == "Add" then
      n1 = stack.pop
      n2 = stack.pop
      stack.push(n2 + n1)
    elsif op == "Sub" then
      n1 = stack.pop
      n2 = stack.pop
      stack.push(n2 - n1)
    elsif op == "Mul" then
      n1 = stack.pop
      n2 = stack.pop
      stack.push(n2 * n1)
    elsif op == "Div" then
      n1 = stack.pop
      n2 = stack.pop
      stack.push(n2 / n1)
    else
      begin
        raise StandardError, "Unknown Instruction " + op
      rescue StandardError => e
        puts e.message
        exit
      end
    end
  end
  puts stack.last
end

execute(["Push", 2, "Add"], [1])
# execute(["Push", 5, "Push", 2, "Sub", "Mul", "Push", 4, "Div"], [2])
# execute(["Push", 4, "Push", 1, "Sub", "Div", "Add"], [0, 3, 10])