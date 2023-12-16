require 'set'

$NFAtransitionType = {}
$epsilonTransitionType = {}

def repeat_until_converge(old, step)
  new = step.call(old)
  while new != old
    old = new
    new = step.call(old)
  end
  return new
end

def all_union(sets, init = [])
  result = init
  for set in sets
    result = result | set
  end
  return result
end

class NFA
  attr_reader :transition, :epsilonTransitions, :start, :finals

  def initialize(transition, epsilonTransitions, start, finals)
    @transition, @epsilonTransitions, @start, @finals = transition, epsilonTransitions, start, finals
  end

  def epsilon_closure_step(ss)
    return all_union(ss.select { |s| @epsilonTransitions.has_key?(s) }.map { |s| @epsilonTransitions[s] }, ss)
  end

  def get_epsilon_closure(ss)
    return repeat_until_converge(ss, method(:epsilon_closure_step))
  end

  def transit(current, sym)
    next_state = all_union(current.select { |s| @transition.has_key?(s) && @transition[s].has_key?(sym) }.map { |s| @transition[s][sym] })
    return get_epsilon_closure(next_state)
  end

  def is_final(ss)
    for s in ss
      if @finals.include?(s)
        return true
      end
    end
    return false
  end
end

def nfa_try_accept(a, s)
  cur = Set.new([a.start])
  puts cur
  for ch in s.split("")
    cur = a.transit(cur, ch)
    puts "->#{cur}"
  end
  return a.is_final(cur)
end

$DFAtransitionType = {}

class DFA
  attr_reader :transition, :start, :finals

  def initialize(transition, epsilonTransitions, start, finals)
    @transition, @start, @finals = transition, start, finals
  end
end

def dfa_try_accept(a, s)
  cur = a.start
  puts cur
  for ch in s.split("")
    cur = a.transition[cur][ch]
    puts "->#{cur}"
  end
  return a.finals.include?(cur)
end

def nfa_to_dfa(n)
  new_states = [n.get_epsilon_closure(Set.new([n.start]))]
  src = 0
  alphabet = Set.new(n.transition.values.map { |h| h.keys }.flatten)
  transdict = {}
  while src < new_states.length
    cur = new_states[src]
    transdict[src] = {}
    for c in alphabet
      c_next = n.transit(cur, c)
      if !new_states.include?(c_next)
        new_states.push(c_next)
      end
      dest = new_states.index(c_next)
      transdict[src][c] = dest
    end
    src += 1
  end
  finals = Set.new(new_states.select { |s| n.is_final(s) }.map { |s| new_states.index(s) })
  return DFA.new(transdict, 0, finals)
end

