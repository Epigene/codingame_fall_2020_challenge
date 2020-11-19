require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

INVENTORY_SIZE = 10

def debug(message, prefix: "=> ")
  STDERR.puts("#{ prefix }#{ message }")
end

# takes in a spell or a potion and returns inventory-compatible array
def deltas(action)
  [action[:delta0], action[:delta1], action[:delta2], action[:delta3]]
end

# @return [String]
def action_type(action)
  if action.is_a?(Hash)
    action[:type]
  else
    action[0]
  end
end

class Array
  # monkeypatches Array to allow adding inventories
  def add(other)
    mem = []

    size.times do |i|
      mem[i] = self[i] + other[i]
    end

    mem
  end
end
