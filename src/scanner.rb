require './src/tokendef'

$skip = /(\s*(\/\/.*\n)?)*/
$group1 = /while\b|do\b|if\b|then\b|else\b|:=|[;{}<=+\-*\/]/
$group2 = /[a-zA-Z][a-zA-Z0-9]*/
$group3 = /[0-9]+/

def token_iter(input)
  token_list = []
  regexp = Regexp.new($skip.source + '((' + $group1.source + ')|(' + $group2.source + ')|(' + $group3.source + '))')
  i = 0
  while result = input.match(regexp, i)
    i = result.end(0)
    result_list = result.captures.last(3)
    if result_list[0] != nil
      token_list.push(KeyWord.new(result_list[0]))
    elsif result_list[1] != nil
      token_list.push(Identifier.new(result_list[1]))
    elsif result_list[2] != nil
      token_list.push(Number.new(result_list[2]))
    else
      begin
        raise StandardError, "Can't match"
      rescue StandardError => e
        puts e.message
        exit
      end
    end
  end
  token_list.push(End.new)
  return token_list
end

sample = """
{
    i := 10;
    while 0 < i do
      i := i - 1
}
"""

sample2 = """
{
    i := 10;        // this is comment.
    while 0 < i do
      i := i - 1
}
"""

p token_iter(sample)