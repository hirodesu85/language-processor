require './src/regexp'
require './src/fsa'

$state_counter = 0

def new_states
  $state_counter += 1
  return $state_counter
end

def dict_value(s, d, default = Set.new)
  if d.include?(s)
    return d[s]
  else
    return default
  end
end

def simple_dict_union(d1, d2)
  result = (d1.keys | d2.keys).each_with_object({}) do |key, result|
    result[key] = dict_value(key, d1) | dict_value(key, d2)
  end
  return result
end

def eps_union(e1, e2)
  return simple_dict_union(e1, e2)
end

def nfa_trans_union(t1, t2)
  empty_dict = {}
  result = (t1.keys | t2.keys).each_with_object({}) do |key, result|
    result[key] = simple_dict_union(dict_value(key, t1, empty_dict), dict_value(key, t2, empty_dict))
  end
  return result
end

def end_state(n)
  if n.finals.length != 1
    raise "NFA must have exactly one final state"
  end
  return n.finals.first
end

def rx_to_nfa(rx, alphabet)
  start = new_states
  dest = new_states
  case rx
  when RxChar
    return NFA.new({start => {rx.ch => Set.new([dest])}}, {}, start, Set.new([dest]))
  when RxEmpty
    return NFA.new({}, {start => Set.new([dest])}, start, Set.new([dest]))
  when RxAny
    transition = {start => alphabet.each_with_object({}) { |ch, result| result[ch] = Set.new([dest]) }}
    return NFA.new(transition, {}, start, Set.new([dest]))
  when RxSeq
    l = rx_to_nfa(rx.left, alphabet)
    r = rx_to_nfa(rx.right, alphabet)
    l_end = end_state(l)
    r_end = end_state(r)
    eps = eps_union({l_end => Set.new([r.start])}, eps_union(l.epsilonTransitions, r.epsilonTransitions))
    return NFA.new(nfa_trans_union(l.transition, r.transition), eps, l.start, Set.new([r_end]))
  when RxOr
    l = rx_to_nfa(rx.left, alphabet)
    r = rx_to_nfa(rx.right, alphabet)
    l_end = end_state(l)
    r_end = end_state(r)
    eps = eps_union({start => Set.new([l.start, r.start]), l_end => Set.new([dest]), r_end => Set.new([dest])}, eps_union(l.epsilonTransitions, r.epsilonTransitions))
    return NFA.new(nfa_trans_union(l.transition, r.transition), eps, start, Set.new([dest]))
  when RxRepeat
    n = rx_to_nfa(rx.rx, alphabet)
    n_end = end_state(n)
    eps = eps_union({start => Set.new([n.start, dest]), n_end => Set.new([n.start, dest])}, n.epsilonTransitions)
    return NFA.new(n.transition, eps, start, Set.new([dest]))
  else
    begin
      raise StandardError, "Unknown rx #{rx}"
    rescue StandardError => e
      puts e.message
      exit
    end
  end
end

rx2 = RxSeq.new(RxOr.new(RxChar.new('a'), RxEmpty.new), RxChar.new('b'))
p rx_to_nfa(rx2, ['a', 'b'])
p nfa_to_dfa(rx_to_nfa(rx2, ['a', 'b']))