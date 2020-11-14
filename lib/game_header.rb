require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

def debug(message, prefix: "=> ")
  STDERR.puts("#{ prefix }#{ message }")
end
