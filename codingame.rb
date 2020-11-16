require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

def debug(message, prefix: "=> ")
  STDERR.puts("#{ prefix }#{ message }")
end

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

      max_cast_id =
        position[:actions].max_by do |id, data|
          if SPELL_TYPES.include?(data[:type])
            id
          else
            -1
          end
        end.first

      # 1. learning
      #   removes learned spell from list
      #   adds a spell with correct id to own spells
      position.dup.tap do |p|
        p.delete(id)
        p[:actions][max_cast_id.next] = LEARNED_SPELL_DATA[max_cast_id.next]
        p[:meta][:turn] += 1
      end
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

class GameTurn
  # Given wood 2 spells, ingredient relative costs
  COSTS = {
    delta0: 1,
    delta1: 3,
    delta2: 5,
    delta3: 7
  }.freeze

  INVENTORY_SIZE = 10

  attr_reader :actions, :me, :opp, :meta

  def initialize(actions:, me:, opp:, meta: {turn: 1})
    actions.each do |k, v|
      debug("#{ k } => #{ v },", prefix: "")
    end
    @actions = actions

    @me = me
    @opp = opp

    debug("me: #{ me }")
    # debug("opp: #{ opp }")

    @meta = meta
    debug("meta: #{ meta }")
  end

  # The only public API, returns the preferable move string
  def move
    brewable_potion = potions.find { |id, potion| i_can_brew?(potion) }

    unless brewable_potion.nil?
      return "BREW #{ brewable_potion[0] } Brewin' #{ brewable_potion[0] }"
    end

    # nothing brewable, let's learn some spells!
    if spell_to_learn_id
      return "LEARN #{ spell_to_learn_id } Studyin'"
    end

    # nothing brewable, let's spell towards the simplest potion
    if simplest_potion_id
      target_inventory = deltas(potions[simplest_potion_id]).map(&:abs)

      return next_step_towards(target_inventory)
    end

    # "WAIT"
    raise("Dunno what to do!")
  end

  # V2, uses perspective cruncher
  # Cruncher has the brute-forcing component that is reliable and deterministic.
  # And the goal component, which I am not sure about at this point.
  # Goal could be:
  # 1. Always leftmost potion, snag dat bonus
  # 2. Always the priciest potion
  # 3. always the quickest to make (but this depends on spells, dont it?)
  # 4. cost/benefit idea, but also depends on spell availability.
  # 5. can theoretically use perspective cruncher to evaluate cost to make any resource
  # 6. possibly less random, would be to use a graph structure to determine how many resources I
  #    can (or could) make in some most efficient setup
  #
  # For now going for 1. always leftmost potion!
  #def move
  #  GameSimulator
  #end

  private

    # Just potion actions (have price), sorted descending by price
    #
    # @return [Hash]
    def potions
      @potions ||= actions.to_a.
        select{ |id, data| data[:type] == "BREW" }.
        sort_by{ |id, data| -data[:price] }.
        to_h
    end

    def my_spells
      @my_spells ||= actions.to_a.
        select{ |id, data| data[:type] == "CAST" }.
        to_h
    end

    def tomes
      @tomes ||= actions.to_a.
        select{ |id, data| data[:type] == "LEARN" }.
        to_h
    end

    def opp_spells
    end

    # @potion [Hash] # {:delta0=>0, :delta1=>-2, :delta2=>0, :delta3=>0}
    # @return [Integer] # the relative cost to make a potion from empty inv
    def cost_in_moves(potion)
      costs = potion.slice(*COSTS.keys).map{ |k, v| v * COSTS[k] }

      # minusing since potion deltas are negative
      -costs.sum
    end

    # @return [Integer], the id of simplest potion in the market
    def simplest_potion_id
      return @simplest_potion_id if defined?(@simplest_potion_id)

      @simplest_potion_id = potions.
        map{ |id, potion| [id, cost_in_moves(potion)] }.
        sort_by{|id, cost| cost }.
        first[0]
    end

    TOMES_TO_CONSIDER = [0, 1].freeze

    # For now assuming that all 'degeneration' spells are bad, and skipping them
    #
    # @return [Integer, nil]
    def spell_to_learn_id
      return @spell_to_learn_id if defined?(@spell_to_learn_id)

      return @spell_to_learn_id = nil if meta[:turn] > 15

      # first pass, looking over up to fourth slot for pure giver spells
      spell_to_learn =
        tomes.find do |id, spell|
          spell[:tome_index] == 0 && pure_giver_spell?(spell)
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[:tome_index] == 1 && pure_giver_spell?(spell) && me[:inv][0] >= 1
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[:tome_index] == 2 && pure_giver_spell?(spell) && me[:inv][0] >= 2
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[:tome_index] == 3 && pure_giver_spell?(spell) && me[:inv][0] >= 3
        end

      # first candidate is free
      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[:tome_index] == 0 && !degeneration_spell?(spell)
        end

      # but subsequent need to consider tax
      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[:tome_index] == 1 && !degeneration_spell?(spell) && me[:inv][0] >= 1
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[:tome_index] == 2 && !degeneration_spell?(spell) && me[:inv][0] >= 2
        end

      return @spell_to_learn_id = nil if spell_to_learn.nil?

      @spell_to_learn_id = spell_to_learn[0]
    end

    # A spell is a degenerator if it's highest consumed ingredient tier is higher than produced tier
    def degeneration_spell?(spell)
      (deltas(spell) - [0]).last.negative?
    end

    def pure_giver_spell?(spell)
      deltas(spell).find(&:negative?).nil?
    end

    # Killer method, considers inventory now, target, spells available.
    # Assumes brewing is not possible, and assumes there's a clear unchanging
    # hirearchy of ingredients (3>2>1>0)
    #
    # @target_inventory [Array] # [1, 2, 3, 4]
    # @return [String]
    def next_step_towards(target_inventory)
      whats_missing = inventory_delta(me[:inv], target_inventory)

      if whats_missing[3] > 0
        spells_for_getting_yellow =
          my_spells.select{ |id, spell| spell[:delta3].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_yellow.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Yello for #{ target_inventory }" if castable_spell
      end

      if whats_missing[2] > 0 || (whats_missing[3] > 0 && me[:inv][2] == 0)
        spells_for_getting_orange =
          my_spells.select{ |id, spell| spell[:delta2].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_orange.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Oranges for #{ target_inventory }" if castable_spell
      end

      if whats_missing[1] > 0 || ((whats_missing[2] > 0 || whats_missing[3] > 0) && me[:inv][1] == 0)
        spells_for_getting_green =
          my_spells.select{ |id, spell| spell[:delta1].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_green.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Goo for #{ target_inventory }" if castable_spell
      end

      if (whats_missing[0] > 0 || (whats_missing[1] > 0 || whats_missing[2] > 0 || whats_missing[3] > 0) && me[:inv][0] == 0)
        spells_for_getting_blue =
          my_spells.select{ |id, spell| spell[:delta0].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_blue.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Aqua for #{ target_inventory }" if castable_spell
      end

      "REST I'm beat while working towards #{ target_inventory }"
    end

    # @spell [Hash] # {:delta0=>0, :delta1=>-1, :delta2=>0, :delta3=>1, :castable=>true}
    # @return [Boolean]
    def i_can_cast?(spell)
      return false unless spell[:castable]

      # can be negative if condenses to better
      items_produced = deltas(spell).sum

      # overfilling inventory detected!
      return false if items_produced + me[:inv].sum > INVENTORY_SIZE

      missing_for_casting = inventory_delta(me[:inv], deltas(spell).map(&:-@))

      !missing_for_casting.sum.positive?
    end

    # takes in a spell or a potion and returns in-ventory-compatible array
    def deltas(action)
      [action[:delta0], action[:delta1], action[:delta2], action[:delta3]]
    end

    # Returns positions and counts that are missing
    def inventory_delta(now, target)
      (0..3).map do |i|
        have = now[i]
        need = target[i]

        if have >= need
          0
        else
          need - have
        end
      end
    end

    # @potion [Hash] # {:delta0=>0, :delta1=>-2, :delta2=>0, :delta3=>0}
    # @return [Boolean]
    def i_can_brew?(potion)
      problems =
        (0..3).to_a.map do |i|
          next if (me[:inv][i] + potion["delta#{ i }".to_sym]) >= 0

          i
        end

      can = problems.compact.none?

      # debug("I can brew #{ potion }: #{ can }")

      can
    end
end

# game loop
SIMULATOR = GameSimulator.new

@turn = 1

loop do
  action_count = gets.to_i # the number of spells and recipes in play

  actions = {}

  action_count.times do
    # action_id: the unique ID of this spell or recipe
    # action_type: in the first league: BREW; later: CAST, OPPONENT_CAST, LEARN, BREW
    # delta0: tier-0 ingredient change
    # delta1: tier-1 ingredient change
    # delta2: tier-2 ingredient change
    # delta3: tier-3 ingredient change
    # price: the price in rupees if this is a potion
    # tome_index: in the first two leagues: always 0; later: the index in the tome if this is a tome spell, equal to the read-ahead tax; For brews, this is the value of the current urgency bonus
    # tax_count: in the first two leagues: always 0; later: the amount of taxed tier-0 ingredients you gain from learning this spell; For brews, this is how many times you can still gain an urgency bonus
    # castable: in the first league: always 0; later: 1 if this is a castable player spell
    # repeatable: for the first two leagues: always 0; later: 1 if this is a repeatable player spell
    action_id, action_type, delta0, delta1, delta2, delta3, price, tome_index, tax_count, castable, repeatable = gets.split(" ")
    action_id = action_id.to_i

    actions[action_id.to_i] = {
      type: action_type,
      delta0: delta0.to_i,
      delta1: delta1.to_i,
      delta2: delta2.to_i,
      delta3: delta3.to_i,
      price: price.to_i,
      tome_index: tome_index.to_i,
      tax_count: tax_count.to_i,
      castable: castable.to_i == 1,
      repeatable: repeatable.to_i == 1
    }
  end

  inv0, inv1, inv2, inv3, score = gets.split(" ").map(&:to_i)

  me = {
    inv: [inv0, inv1, inv2, inv3],
    score: score
  }

  inv0, inv1, inv2, inv3, score = gets.split(" ").map(&:to_i)

  opp = {
    inv: [inv0, inv1, inv2, inv3],
    score: score
  }

  turn = GameTurn.new(
    meta: {turn: @turn},
    actions: actions,
    me: me,
    opp: opp
  )

  # in the first league: BREW <id> | WAIT; later: BREW <id> | CAST <id> [<times>] | LEARN <id> | REST | WAIT
  puts turn.move
  @turn += 1
end

