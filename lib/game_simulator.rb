class GameSimulator
  # This class provides methods to advance game state into the future to a certain degree
  # opponent moves can naturally not be simulated, and impossible to know what new spells
  # and potions will appear later.

  PURE_GIVER_IDS = [2, 3, 4, 12, 13, 14, 15, 16].to_set.freeze
  GOOD_SPELL_IDS = [18, 17, 38, 39, 40, 30, 34].to_set.freeze

  LEARNABLE_SPELLS = {
    # id => [deltas, can be multicast, hard_skip]
    2 => [[1, 1, 0, 0], false, false], # pure giver
    3 => [[0, 0, 1, 0], false, false], # pure giver
    4 => [[3, 0, 0, 0], false, false], # pure giver
    12 => [[2, 1, 0, 0], false, false], # pure giver
    13 => [[4, 0, 0, 0], false, false], # pure giver
    14 => [[0, 0, 0, 1], false, false], # pure giver
    15 => [[0, 2, 0, 0], false, false], # pure giver
    16 => [[1, 0, 1, 0], false, false], # pure giver

    18 => [[-1, -1, 0, 1], true, false], # IMBA
    17 => [[-2, 0, 1, 0], true, false], # GREAT!, better version of 11
    38 => [[-2, 2, 0, 0], true, false], # OK
    39 => [[0, 0, -2, 2], true, false], # OK
    40 => [[0, -2, 2, 0], true, false], # OK
    30 => [[-4, 0, 1, 1], true, false], # OK
    34 => [[-2, 0, -1, 2], true, false], # OK

    0 => [[-3, 0, 0, 1], true, false], # so-so
    1 => [[3, -1, 0, 0], true, false], # degen
    5 => [[2, 3, -2, 0], true, false], # degen
    6 => [[2, 1, -2, 1], true, false], # so-so, lossy
    7 => [[3, 0, 1, -1], true, false], # degen
    8 => [[3, -2, 1, 0], true, false], # so-so, lossy
    9 => [[2, -3, 2, 0], true, false], # so-so, lossy
    10 => [[2, 2, 0, -1], true, false], # degen
    11 => [[-4, 0, 2, 0], true, false], # so-so, bad version of 17
    19 => [[0, 2, -1, 0], true, false], # degen
    20 => [[2, -2, 0, 1], true, false], # so-so, lossy
    21 => [[-3, 1, 1, 0], true, false], # lossy
    22 => [[0, 2, -2, 1], true, false], # so-so, twist
    23 => [[1, -3, 1, 1], true, false], # so-so, twist
    24 => [[0, 3, 0, -1], true, false], # degen
    25 => [[0, -3, 0, 2], true, false], # so-so
    26 => [[1, 1, 1, -1], true, false], # degen
    27 => [[1, 2, -1, 0], true, false], # degen
    28 => [[4, 1, -1, 0], true, false], # degen
    31 => [[0, 3, 2, -2], true, false], # degen
    32 => [[1, 1, 3, -2], true, false], # degen
    35 => [[0, 0, -3, 3], true, false], # so-so
    36 => [[0, -3, 3, 0], true, false], # so-so
    37 => [[-3, 3, 0, 0], true, false], # so-so
    33 => [[-5, 0, 3, 0], true, true], # mehh
    29 => [[-5, 0, 0, 2], true, true], # mehh
    41 => [[0, 0, 2, -1], true, false] # degen
  }.freeze

  LEARNED_SPELL_DATA = {
    2 => {:type=>"CAST",:repeatable=>false, :delta0=>1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    3 => {:type=>"CAST",:repeatable=>false, :delta0=>0, :delta1=>0, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    4 => {:type=>"CAST",:repeatable=>false, :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    12 => {:type=>"CAST",:repeatable=>false, :delta0=>2, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    13 => {:type=>"CAST",:repeatable=>false, :delta0=>4, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    14 => {:type=>"CAST",:repeatable=>false, :delta0=>0, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    15 => {:type=>"CAST",:repeatable=>false, :delta0=>0, :delta1=>2, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    16 => {:type=>"CAST",:repeatable=>false, :delta0=>1, :delta1=>0, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    18 => {:type=>"CAST",:repeatable=>true, :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    17 => {:type=>"CAST",:repeatable=>true, :delta0=>-2, :delta1=>0, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    38 => {:type=>"CAST",:repeatable=>true, :delta0=>-2, :delta1=>2, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    39 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>0, :delta2=>-2, :delta3=>2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    40 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>-2, :delta2=>2, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    30 => {:type=>"CAST",:repeatable=>true, :delta0=>-4, :delta1=>0, :delta2=>1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    34 => {:type=>"CAST",:repeatable=>true, :delta0=>-2, :delta1=>0, :delta2=>-1, :delta3=>2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    0 => {:type=>"CAST",:repeatable=>true, :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    1 => {:type=>"CAST",:repeatable=>true, :delta0=>3, :delta1=>-1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    5 => {:type=>"CAST",:repeatable=>true, :delta0=>2, :delta1=>3, :delta2=>-2, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    6 => {:type=>"CAST",:repeatable=>true, :delta0=>2, :delta1=>1, :delta2=>-2, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    7 => {:type=>"CAST",:repeatable=>true, :delta0=>3, :delta1=>0, :delta2=>1, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    8 => {:type=>"CAST",:repeatable=>true, :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    9 => {:type=>"CAST",:repeatable=>true, :delta0=>2, :delta1=>-3, :delta2=>2, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    10 => {:type=>"CAST",:repeatable=>true, :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    11 => {:type=>"CAST",:repeatable=>true, :delta0=>-4, :delta1=>0, :delta2=>2, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    19 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>2, :delta2=>-1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    20 => {:type=>"CAST",:repeatable=>true, :delta0=>2, :delta1=>-2, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    21 => {:type=>"CAST",:repeatable=>true, :delta0=>-3, :delta1=>1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    22 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>2, :delta2=>-2, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    23 => {:type=>"CAST",:repeatable=>true, :delta0=>1, :delta1=>-3, :delta2=>1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    24 => {:type=>"CAST",:repeatable=>true, :delta0=>1, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    25 => {:type=>"CAST",:repeatable=>true, :delta0=>1, :delta1=>-3, :delta2=>0, :delta3=>2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    26 => {:type=>"CAST",:repeatable=>true, :delta0=>1, :delta1=>1, :delta2=>1, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    27 => {:type=>"CAST",:repeatable=>true, :delta0=>1, :delta1=>2, :delta2=>-1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    28 => {:type=>"CAST",:repeatable=>true, :delta0=>4, :delta1=>1, :delta2=>-1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    31 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>3, :delta2=>2, :delta3=>-2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    32 => {:type=>"CAST",:repeatable=>true, :delta0=>1, :delta1=>1, :delta2=>3, :delta3=>-2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    35 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>0, :delta2=>-3, :delta3=>3, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    36 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>-3, :delta2=>3, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    37 => {:type=>"CAST",:repeatable=>true, :delta0=>-3, :delta1=>3, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    33 => {:type=>"CAST",:repeatable=>true, :delta0=>-5, :delta1=>0, :delta2=>3, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    29 => {:type=>"CAST",:repeatable=>true, :delta0=>-5, :delta1=>0, :delta2=>0, :delta3=>2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
    41 => {:type=>"CAST",:repeatable=>true, :delta0=>0, :delta1=>0, :delta2=>2, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true},
  }

  POTIONS = {
    42 => [[2, 2, 0, 0], 6],
    43 => [[3, 2, 0, 0], 7],
    44 => [[0, 4, 0, 0], 8],
    45 => [[2, 0, 2, 0], 8],
    46 => [[2, 3, 0, 0], 8],
    47 => [[3, 0, 2, 0], 9],
    48 => [[0, 2, 2, 0], 10],
    49 => [[0, 5, 0, 0], 10],
    50 => [[2, 0, 0, 2], 10],
    51 => [[2, 0, 3, 0], 11],
    52 => [[3, 0, 0, 2], 11],
    53 => [[0, 0, 4, 0], 12],
    54 => [[0, 2, 0, 2], 12],
    55 => [[0, 3, 2, 0], 12],
    56 => [[0, 2, 3, 0], 13],
    57 => [[0, 0, 2, 2], 14],
    58 => [[0, 3, 0, 2], 14],
    59 => [[2, 0, 0, 3], 14],
    60 => [[0, 0, 5, 0], 15],
    61 => [[0, 0, 0, 4], 16],
    62 => [[0, 2, 0, 3], 16],
    63 => [[0, 0, 3, 2], 17],
    64 => [[0, 0, 2, 3], 18],
    65 => [[0, 0, 0, 5], 20],
    66 => [[2, 1, 0, 1], 9],
    67 => [[0, 2, 1, 1], 12],
    68 => [[1, 0, 2, 1], 12],
    69 => [[2, 2, 2, 0], 13],
    70 => [[2, 2, 0, 2], 15],
    71 => [[2, 0, 2, 2], 17],
    72 => [[0, 2, 2, 2], 19],
    73 => [[1, 1, 1, 1], 12],
    74 => [[3, 1, 1, 1], 14],
    75 => [[1, 3, 1, 1], 16],
    76 => [[1, 1, 3, 1], 18],
    77 => [[1, 1, 1, 3], 20]
  }.freeze

  SPELL_TYPES = ["CAST", "OPPONENT_CAST"].freeze

  def initialize; end

  # Returns the init parameters for the GameTurn that would follow after a certain move
  # Caches the outcomes, since same state and same move will always result in the same outcome
  #
  # @position [Hash] #
  # @return [Hash]
  def result(position:, move: "")
    portions = move.split(" ")
    verb = portions.first #=> "LEARN", "REST", "CAST"

    case verb
    when "REST"

    when "LEARN"
      id = portions[1].to_i

      # needed to know what will be the added spell's id
      max_cast_id =
        position[:actions].max_by do |id, data|
          if SPELL_TYPES.include?(data[:type])
            id
          else
            -1
          end
        end.first

      learn_index = position[:actions][id][:tome_index]

      # 1. learning
      #   removes learned spell from list
      #   adds a spell with correct id to own spells
      p = position.dup
      p[:actions].reject!{ |k, v| k == id }

      p[:actions].transform_values! do |v|
        if v[:type] == "LEARN"
          if v[:tome_index] > learn_index
            v[:tome_index] -= 1
          end

          if v[:tome_index] < learn_index
            v[:tax_count] += 1
          end

          v
        else
          v
        end
      end

      p[:actions][max_cast_id.next] = LEARNED_SPELL_DATA[id]
      p[:meta][:turn] += 1
      p[:me][:inv][0] -= learn_index

      p
    when "CAST"
      # 2. casting
      #   changes my inv accordingly
      #   changes spell castability accordingly
    else
      {error: "verb '#{ verb }' not supported"}
    end
  end

  # This is the brute-forcing component.
  # Uses heuristics to try most promising paths first
  # @return [Array<String>]
  def moves_towards(inv:, start:, just_rested: false)
    # 1. identify legal and useful moves.
    #      Remember that several repeats of a multicastable spell are different possible actions
    #      Never rest twice in a row
    # 2. loop over OK moves, get results
    # 3. Loop over results with 1. again. Can use heuristics to try promising outcomes first
  end
end
