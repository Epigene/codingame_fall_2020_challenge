require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

INVENTORY_SIZE = 10

def debug(message, prefix: "=> ")
  STDERR.puts("#{ prefix }#{ message }")
end

# takes in a spell or a potion and returns inventory-compatible array
def deltas(action)
  if action.is_a?(Hash)
    [action[:delta0], action[:delta1], action[:delta2], action[:delta3]]
  else
    action[1..4]
  end
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

class GameSimulator
  # This class provides methods to advance game state into the future to a certain degree
  # opponent moves can naturally not be simulated, and impossible to know what new spells
  # and potions will appear later.
  class ::SimulatorError < RuntimeError; end
  #                 78, 82 are default 1st spell ids, the [2, 0, 0, 0] spells
  PURE_GIVER_IDS = [78, 82, 2, 3, 4, 12, 13, 14, 15, 16].to_set.freeze
  GOOD_SPELL_IDS = [18, 17, 38, 39, 40, 30, 34].to_set.freeze

  LEARNABLE_SPELLS = {
    # id => [deltas,  can be multicast, hard_skip, value_per_turn]
    2 => [1, 1, 0, 0, false, false, 3], # pure giver
    3 => [0, 0, 1, 0, false, false, 3], # pure giver
    4 => [3, 0, 0, 0, false, false, 3], # pure giver
    12 => [2, 1, 0, 0, false, false, 4], # pure giver
    13 => [4, 0, 0, 0, false, false, 4], # pure giver
    14 => [0, 0, 0, 1, false, false, 4], # pure giver
    15 => [0, 2, 0, 0, false, false, 4], # pure giver
    16 => [1, 0, 1, 0, false, false, 4], # pure giver

    18 => [-1, -1, 0, 1, true, false, 1], # IMBA, huge multicast potential, special in that it takes two givers
    17 => [-2, 0, 1, 0, true, false, 1], # GREAT!, better version of 11
    38 => [-2, 2, 0, 0, true, false, 2], # OK
    39 => [0, 0, -2, 2, true, false, 2], # OK
    40 => [0, -2, 2, 0, true, false, 2], # OK
    30 => [-4, 0, 1, 1, true, false, 3], # OK
    34 => [-2, 0, -1, 2, true, false, 3], # OK, takes two givers

    31 => [0, 3, 2, -2, true, false, 4], # degen. excellent if you have [0, 0, 0, 1]


    0 => [-3, 0, 0, 1, true, false, 1], # so-so-to-OK
    21 => [-3, 1, 1, 0, true, false, 2], # so-so, lossy
    37 => [-3, 3, 0, 0, true, false, 3], # so-so-to-OK
    1 => [3, -1, 0, 0, true, false, 1], # degen
    5 => [2, 3, -2, 0, true, false, 2], # degen
    6 => [2, 1, -2, 1, true, false, 2], # so-so, lossy
    7 => [3, 0, 1, -1, true, false, 2], # degen
    8 => [3, -2, 1, 0, true, false, 2], # so-so, lossy
    9 => [2, -3, 2, 0, true, false, 2], # so-so, lossy
    10 => [2, 2, 0, -1, true, false, 2], # degen
    19 => [0, 2, -1, 0, true, false, 1], # degen
    20 => [2, -2, 0, 1, true, false, 2], # so-so, lossy
    22 => [0, 2, -2, 1, true, false, 2], # so-so, twist
    23 => [1, -3, 1, 1, true, false, 2], # so-so, twist
    24 => [0, 3, 0, -1, true, false, 2], # degen
    25 => [0, -3, 0, 2, true, false, 2], # so-so
    26 => [1, 1, 1, -1, true, false, 2], # degen, excellent multicast
    27 => [1, 2, -1, 0, true, false, 2], # degen, good multicast
    28 => [4, 1, -1, 0, true, false, 3], # degen, low chance to multicast :(
    32 => [1, 1, 3, -2, true, false, 4], # degen
    36 => [0, -3, 3, 0, true, false, 3], # so-so
    35 => [0, 0, -3, 3, true, false, 3], # so-so
    11 => [-4, 0, 2, 0, true, false, 2], # so-so, bad version of 17
    33 => [-5, 0, 3, 0, true, true, 4], # so-so
    29 => [-5, 0, 0, 2, true, true, 3], # mehh
    41 => [0, 0, 2, -1, true, false, 2] # degen, good chance to multicast
  }.freeze

  LEARNED_SPELL_DATA = {
    2 => ["CAST", 1, 1, 0, 0, true, false],
    3 => ["CAST", 0, 0, 1, 0, true, false],
    4 => ["CAST", 3, 0, 0, 0, true, false],
    12 => ["CAST", 2, 1, 0, 0, true, false],
    13 => ["CAST", 4, 0, 0, 0, true, false],
    14 => ["CAST", 0, 0, 0, 1, true, false],
    15 => ["CAST", 0, 2, 0, 0, true, false],
    16 => ["CAST", 1, 0, 1, 0, true, false],
    18 => ["CAST", -1, -1, 0, 1, true, true],
    17 => ["CAST", -2, 0, 1, 0, true, true],
    38 => ["CAST", -2, 2, 0, 0, true, true],
    39 => ["CAST", 0, 0, -2, 2, true, true],
    40 => ["CAST", 0, -2, 2, 0, true, true],
    30 => ["CAST", -4, 0, 1, 1, true, true],
    34 => ["CAST", -2, 0, -1, 2, true, true],
    0 => ["CAST", -3, 0, 0, 1, true, true],
    1 => ["CAST", 3, -1, 0, 0, true, true],
    5 => ["CAST", 2, 3, -2, 0, true, true],
    6 => ["CAST", 2, 1, -2, 1, true, true],
    7 => ["CAST", 3, 0, 1, -1, true, true],
    8 => ["CAST", 3, -2, 1, 0, true, true],
    9 => ["CAST", 2, -3, 2, 0, true, true],
    10 => ["CAST", 2, 2, 0, -1, true, true],
    11 => ["CAST", -4, 0, 2, 0, true, true],
    19 => ["CAST", 0, 2, -1, 0, true, true],
    20 => ["CAST", 2, -2, 0, 1, true, true],
    21 => ["CAST", -3, 1, 1, 0, true, true],
    22 => ["CAST", 0, 2, -2, 1, true, true],
    23 => ["CAST", 1, -3, 1, 1, true, true],
    24 => ["CAST", 1, 3, 0, -1, true, true],
    25 => ["CAST", 1, -3, 0, 2, true, true],
    26 => ["CAST", 1, 1, 1, -1, true, true],
    27 => ["CAST", 1, 2, -1, 0, true, true],
    28 => ["CAST", 4, 1, -1, 0, true, true],
    31 => ["CAST", 0, 3, 2, -2, true, true],
    32 => ["CAST", 1, 1, 3, -2, true, true],
    35 => ["CAST", 0, 0, -3, 3, true, true],
    36 => ["CAST", 0, -3, 3, 0, true, true],
    37 => ["CAST", -3, 3, 0, 0, true, true],
    33 => ["CAST", -5, 0, 3, 0, true, true],
    29 => ["CAST", -5, 0, 0, 2, true, true],
    41 => ["CAST", 0, 0, 2, -1, true, true]
  }.freeze

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

  def self.the_instance
    @the_instance ||= new
  end

  def initialize; end

  # Returns the init parameters for the GameTurn that would follow after a certain move
  # Caches the outcomes, since same state and same move will always result in the same outcome
  #
  # @position [Hash] #
  # @return [Hash]
  # @return [String] # err message if there's err
  def result(position:, move:)
    portions = move.split(" ")
    verb = portions.first #=> "LEARN", "REST", "CAST"

    case verb
    when "REST"
      if position.dig(:me, 6).to_s.start_with?("REST")
        return "do not rest twice in a row!"
      end

      p = dup_of(position)

      p[:actions].transform_values! do |v|
        if action_type(v) == "CAST"
          v[5] = true
          v
        else
          v
        end
      end

      p[:me][5] += 1
      p[:me][6] = move

      p
    when "LEARN"
      id = portions[1].to_i
      learned_spell = position[:actions][id]
      learn_index = learned_spell[5]

      if learn_index > position[:me][0]
        return "insufficient aqua for learning tax!"
      end

      # needed to know what will be the added spell's id
      max_cast_id =
        position[:actions].max_by do |id, action|
          if SPELL_TYPES.include?(action_type(action))
            id
          else
            -1
          end
        end.first

      # 1. learning
      #   removes learned spell from list
      #   adds a spell with correct id to own spells
      p = dup_of(position)

      p[:actions].reject!{ |k, v| k == id }

      p[:actions].transform_values! do |v|
        if action_type(v) == "LEARN"
          if v[5] > learn_index
            v[5] -= 1
          end

          if v[5] < learn_index
            v[6] += 1
          end

          v
        else
          v
        end
      end

      p[:actions][max_cast_id.next] = LEARNED_SPELL_DATA[id]
      p[:me][5] += 1
      p[:me][6] = move
      p[:me][0] -= learn_index
      p[:me][0] += learned_spell[6] if learned_spell[6].positive?

      p
    when "CAST"
      id = portions[1].to_i
      cast_spell = position[:actions][id]

      return "spell exhausted!" unless cast_spell[5]

      cast_times =
        if portions.size > 2
          portions[2].to_i
        else
          1
        end

      if cast_times > 1 && !cast_spell[6]
        return "spell can't multicast!"
      end

      operation =
        if cast_times == 1
          deltas(cast_spell)
        else
          deltas(cast_spell).map{ |v| v * cast_times}
        end

      casting_check = can_cast?(operation: operation, from: position[:me][0..3])

      if !casting_check[:can]
        if casting_check[:detail] == :insufficient_ingredients
          return "insufficient ingredients for casting!" if cast_times == 1
          return "insufficient ingredients for multicasting!"
        else
          return "casting overfills inventory!"
        end
      end

      p = dup_of(position)

      cast_times.times do
        p[:me][0..3] = p[:me][0..3].add(deltas(cast_spell))
      end

      p[:actions][id][5] = false

      # 2. casting
      #   changes my inv accordingly
      #   changes spell castability accordingly
      p[:me][5] += 1
      p[:me][6] = move
      p
    else
      {error: "verb '#{ verb }' not supported"}
    end
  end

  def dup_of(position)
    # 2.22s
    dupped_actions = position[:actions].dup
    dupped_actions.transform_values!(&:dup)

    {
      actions: dupped_actions,
      me: position[:me].dup
    }

    # # 2.38s
    # {
    #   # actions: position[:actions].map{ |k, v| [k, v.dup]}.to_h,
    #   # actions: position[:actions].each_with_object({}){ |(k, v), mem| mem[k] = v.dup },
    #   me: position[:me].dup
    # }
  end

  MY_MOVES = ["CAST", "LEARN"].to_set.freeze
  DISTANCE_CUTOFF_DELTA = 6
  MAXIMUM_DEPTH = 6

  # This is the brute-forcing component.
  # Uses heuristics to try most promising paths first
  # @target [Array] # target inventory to solve for
  # @start [Hash] # the starting position, actions and me expected
  #
  # @return [Array<String>]
  def moves_towards(target:, start:, path: [], max_depth: MAXIMUM_DEPTH, depth: 0)
    prime_candidate = nil
    moves_to_return = nil

    initial_distance_from_target = distance_from_target(
      target: target, inv: start[:me][0..3]
    )

    return [] if initial_distance_from_target[:distance].zero?

    # debug("Initial distance is #{ initial_distance_from_target }")

    # This cleans position passed on in hopes of saving on dup time, works well
    start[:actions] = start[:actions].select do |_k, v|
      MY_MOVES.include?(action_type(v))
    end.to_h

    max_allowed_learning_moves = max_depth / 2 # in case of odd max debt, learn less

    positions = {path => start}

    ms_spent = 0.0

    (1..max_depth).to_a.each do |generation|
      break if moves_to_return

      if ms_spent > 45
        debug("Quick-returning #{ prime_candidate[0] } due to imminent timeout!")
        return prime_candidate[0]
      end

      past_halfway = generation >= (max_depth / 2).next

      generation_runtime = Benchmark.realtime do
        debug("Starting move and outcome crunch for generation #{ generation }") if past_halfway
        # debug("There are #{ positions.keys.size } positions to check moves for")

        final_iteration = generation == max_depth
        penultimate_iteration = generation == max_depth - 1

        data = []

        ms_spent_in_this_gen = ms_spent

        positions.each_pair do |path, position|
          position_processing_time = Benchmark.realtime do
            already_studied_max_times =
              past_halfway &&
              path.count { |v| v.start_with?("LEARN") } >= max_allowed_learning_moves

            # HH This prevents resting after just learning a spell
            just_learned = position[:me][6].to_s.start_with?("LEARN")

            moves = moves_from(
              position: position,
              skip_resting: final_iteration || just_learned,
              skip_learning: final_iteration || already_studied_max_times
            )
            # debug("There are #{ moves.size } moves that can be made after #{ path }")
            #=> ["REST", "CAST 79"]

            moves.each do |move|
              # 2. loop over OK moves, get results
              outcome =
                begin
                  result(position: positions[path], move: move)
                rescue => e
                  raise("Path #{ path << move } leads to err: '#{ e.message }' in #{ e.backtrace.first }")
                end

              # outcome was an expected invalid move, skipping the outcome
              next if outcome.is_a?(String)

              # 3. evaluate the outcome
              distance_from_target = distance_from_target(
                target: target, inv: outcome[:me][0..3]
              )

              data << [
                [*path, move],
                {
                  outcome: outcome,
                  distance_from_target: distance_from_target
                }
              ]
            end
          end * 1000

          ms_spent_in_this_gen += position_processing_time

          if ms_spent_in_this_gen > 45
            debug("Doing an emergency break out of position processing due to time running out!")
            break
          end
        end

        # debug("There turned out to be #{ moves_to_try.size } moves to check") if past_halfway

        data.sort_by! do |(_move, path), specifics|
          [
            specifics[:distance_from_target][:distance],
            -specifics[:distance_from_target][:bonus]
          ]
        end
        #=> [[move, data], ["CATS 78", {outcome: {actions: {...}}}]]

        prime_candidate = data.first
        prime_specifics = prime_candidate[1]

        # check best move, if with it we're there, done!
        return_prime_candidate =
          if prime_specifics[:distance_from_target][:distance] == 0
            :target_reached
          elsif final_iteration
            :max_depth_reached
          else
            false
          end

        if return_prime_candidate
          debug("Returning prime candidate because #{ return_prime_candidate }")
          moves_to_return = prime_candidate[0]
        else
          # no move got us there, lets go deeper.
          # here's we can inject heuristics of which results to keep and drop for next gen
          # 1. drop outcomes that are too far behind the best variant. Since some spells give 4 in one move,
          #     probably safe to use 8+

          # 1. dropping hopeless variations
          lowest_distance = prime_specifics[:distance_from_target][:distance]

          no_longer_tolerable_distance =
            # the further in we are, the less forgiving of bad variations we are
            if penultimate_iteration
              lowest_distance + DISTANCE_CUTOFF_DELTA - 1
            else
              lowest_distance + DISTANCE_CUTOFF_DELTA
            end

          cutoff_index = nil

          # binding.pry if generation == 4

          data.each.with_index do |(new_path, specifics), i|
            if specifics[:distance_from_target][:distance] < no_longer_tolerable_distance
              next
            end

            # detects no progress towards target past the halfway mark, pure idling here.
            if past_halfway
              if specifics[:distance_from_target][:distance] <= initial_distance_from_target[:distance]
                if specifics[:distance_from_target][:bonus] <= initial_distance_from_target[:bonus]
                  cutoff_index = i
                  break
                end
              end
            end

            cutoff_index = i
            break
          end

          if cutoff_index
            # debug("Cutoff at index #{ cutoff_index } from #{ data.size }")
            debug("Cutoff at index #{ cutoff_index } from OMITTED")
            data = data[0..(cutoff_index-1)]
          else
            debug(
              "Nothing to cut off, "\
              "closest variant has #{ prime_specifics[:distance_from_target] }, "\
              "and furthest has #{ data.last[1][:distance_from_target] }"
            ) if past_halfway
          end

          positions = {}

          data.each do |variation_path, specifics|
            positions[variation_path] = specifics[:outcome]
          end
        end
      end * 1000

      ms_spent += generation_runtime

      debug("Gen #{ generation } ran for #{ generation_runtime.round(1) }ms, totalling #{ ms_spent.round(1) }ms") if past_halfway
    end

    moves_to_return
  end

  # This is the evaluator method.
  # every ingredient that is missing from target is taken to be a distance of [1,2,3,4] respectively
  # ingredients that are more do not reduce distance, but are counted as a bonus
  #
  # @return [Hash]
  def distance_from_target(target:, inv:)
    @distance_cache ||= {}
    key = [target, inv]

    if @distance_cache.key?(key)
      @distance_cache[key]
    else
      sum = target.add(inv.map{|v| -v})
      distance = sum.map.with_index{ |v, i| next unless v.positive?; v*i.next }.compact.sum
      bonus = sum.map.with_index{ |v, i| next unless v.negative?; -v*i.next }.compact.sum

      @distance_cache[key] = {distance: distance, bonus: bonus}
    end
    # sum = target.add(inv.map{|v| -v})
    # distance = sum.map.with_index{ |v, i| next unless v.positive?; v*i.next }.compact.sum
    # bonus = sum.map.with_index{ |v, i| next unless v.negative?; -v*i.next }.compact.sum
    # {distance: distance, bonus: bonus}
  end

  # Does not care about legality much, since simulator will check when deciding outcome.
  # @return [Array<String>]
  def moves_from(position:, skip_resting: false, skip_learning: false)
    moves = []

    all_spells_rested = true
    givers_i_know = nil

    spells =
      position[:actions].select do |id, action|
        action_type(action) == "CAST"
      end

    tomes =
      position[:actions].select do |id, action|
        action_type(action) == "LEARN"
      end

    aquas_on_hand = position[:me][0]

    # returns a net gain of 0 if can't afford learning tax anyway
    net_aqua_gains_from_learning =
      tomes.map do |id, tome|
        gain =
          if aquas_on_hand >= tome[5]
            tome[6] - tome[5]
          else
            0
          end

        [id, gain]
      end

    # can also give 0 and 1 aqua, beware
    best_aqua_giver_from_learning = net_aqua_gains_from_learning.max_by{ |id, gain| gain }

    position[:actions].each do |id, action|
      type = action_type(action)

      if type == "LEARN" && !skip_learning
        try_learning =
          if PURE_GIVER_IDS.include?(id)
            true
          elsif spells.size >= 8
            false
          # elsif # TODO, consider not learning [-5] spells if an advanced aqua giver is not known
          else
            givers_needed = action[1..4].map{ |v| v.negative? } #=> [false, false, true, false]

            givers_i_know ||= spells.select do |id, action|
              !action[1..4].find{ |v| v.negative? }
            end.each_with_object([false, false, false, false]) do |(id, giver), mem|
              mem[0] ||= giver[1].positive?
              mem[1] ||= giver[2].positive?
              mem[2] ||= giver[3].positive?
              mem[3] ||= giver[4].positive?
            end

            even_one_required_but_no_giver =
              givers_needed.find.with_index do |req, i|
                req && !givers_i_know[i]
              end

            !even_one_required_but_no_giver
          end

        moves << "LEARN #{ id }" if try_learning
      elsif type == "CAST"
        unless action[5] # oops, exhausted
          all_spells_rested = false
          next
        end

        times = possible_cast_times(spell: action, inv: position[:me][0..3])

        next if times == 0

        # givers can ever only be cast once
        if times == 1
          only_gives_aquas =
            action[1].positive? && action[2].zero? && action[3].zero? && action[4].zero?

          # preferring to get aquas by learning
          if only_gives_aquas && best_aqua_giver_from_learning && best_aqua_giver_from_learning[1] >= action[1]
            moves << "LEARN #{ best_aqua_giver_from_learning[0] }"
            next
          end
        end

        times.times do |i|
          moves <<
            if i == 0
              "CAST #{ id }"
            else
              "CAST #{ id } #{ i.next }"
            end
        end
      end
    end

    if skip_resting || position[:me][6].to_s.start_with?("REST") || all_spells_rested
    else
      moves << "REST"
    end

    moves.uniq
  end

  # Returns ways can this spell can be cast in. 0, 1 or n(multicast) variants possible.
  # @return [Integer] # number of times the spell can be cast from this inventory
  def possible_cast_times(spell:, inv:)
    # @cast_time_cache ||= {}
    # key = [spell, inv]

    # if @cast_time_cache.key?(key)
    #   @cast_time_cache[key]
    # else
    #   return @cast_time_cache[key] = 0 unless spell[5]

    #   deltas = deltas(spell)

    #   can_cast_once = can_cast?(operation: deltas, from: inv)

    #   return @cast_time_cache[key] = 0 unless can_cast_once[:can]

    #   # here we know that can be cast at least once
    #   return @cast_time_cache[key] = 1 unless spell[6]

    #   # here we know the spell can be repeated
    #   (2..5).to_a.each do |i|
    #     next if can_cast?(operation: deltas.map{ |v| v * i}, from: inv)[:can]

    #     return @cast_time_cache[key] = i-1
    #   end

    #   return @cast_time_cache[key] = 5
    # end

    return 0 unless spell[5]

    deltas = deltas(spell)

    can_cast_once = can_cast?(operation: deltas, from: inv)

    return 0 unless can_cast_once[:can]

    # here we know that can be cast at least once
    return 1 unless spell[6]

    # here we know the spell can be repeated
    (2..5).to_a.each do |i|
      next if can_cast?(operation: deltas.map { |v| v * i }, from: inv)[:can]

      return i-1
    end

    return 5
  end

  NO_INGREDIENTS = {can: false, detail: :insufficient_ingredients}.freeze
  INVENTORY_OVERFLOW = {can: false, detail: :overflow}.freeze
  CANN = {can: true}.freeze

  # Takes into account the two constraints
  # - ingredients must suffice
  # - inventory of 10 may not be exceeded
  #
  # @operation [Array] # deltas
  # @return [Hash] {can: true/false, detail: :insufficient_ingredients/:overflow}
  def can_cast?(operation:, from:)
    # @cast_cache ||= {}
    # key = [operation, from]

    # if @cast_cache.key?(key)
    #   @cast_cache[key]
    # else
    #   result = from.add(operation)

    #   return @cast_cache[key] = {can: false, detail: :insufficient_ingredients} if result.find{ |v| v.negative? }
    #   return @cast_cache[key] = {can: false, detail: :overflow} if result.sum > INVENTORY_SIZE
    #   @cast_cache[key] = {can: true}
    # end
    result = from.add(operation)

    return NO_INGREDIENTS if result.find{ |v| v.negative? }
    return INVENTORY_OVERFLOW if result.sum > INVENTORY_SIZE

    CANN
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

  attr_reader :actions, :me, :opp

  def initialize(actions:, me:, opp:)
    actions.each do |k, v|
      debug("#{ k } => #{ v },", prefix: "")
    end
    @actions = actions

    @me = me
    @opp = opp

    debug("me: #{ me }")
    # debug("opp: #{ opp }")
  end

  # V1, a bunch of else-ifs
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
  def move_v2
    move = nil
    # realtime
    elapsed = Benchmark.realtime do
      if me[5] < 10 # before 20th turn
        closest_pure_giver_spell =
          tomes.find do |id, tome|
            GameSimulator::PURE_GIVER_IDS.include?(id)
          end
        #=> [id, tome]

        if closest_pure_giver_spell
          tax_for_giver = [closest_pure_giver_spell[1][5], 0].max

          the_moves = GameSimulator.the_instance.moves_towards(
            start: position, target: [tax_for_giver, 0, 0, 0]
          )

          move =
            if the_moves == []
              # oh, already there, let's learn
              "LEARN #{ closest_pure_giver_spell[0] }"
            else
              "#{ the_moves.first } let's try learning #{ closest_pure_giver_spell[0] } via [#{ the_moves.join(", ") }]"
            end

          return move
        end
      end

      if me[5] < 4 # before 4th turn, hardcoded learning
        # binding.pry
        # givers_i_know
        # tomes
      end

      leftmost_potion_with_bonus =
        potions.find { |id, potion| potion[:tome_index] == 3 }
      #[id, potion]

      potion_to_work_towards =
        if leftmost_potion_with_bonus
          leftmost_potion_with_bonus
        else
          [simplest_potion_id, potions[simplest_potion_id]]
        end

      the_moves = GameSimulator.the_instance.moves_towards(
        start: position, target: deltas(potion_to_work_towards[1]).map(&:-@)
      )

      move =
        if the_moves == []
          # oh, already there, let's brew
          "BREW #{ potion_to_work_towards[0] }"
        else
          "#{ the_moves.first } let's brew #{ potion_to_work_towards[0] } via [#{ the_moves.join(", ") }]"
        end
    end

    debug("move_v2 took #{ (elapsed * 1000.0).round }ms")

    move
  end

  private

    def position
      @position ||= {
        actions: actions,
        me: me
      }
    end

    # Just potion actions (have price), sorted descending by price
    #
    # @return [Hash]
    def potions
      @potions ||= actions.to_a.
        select{ |id, action| action_type(action) == "BREW" }.
        sort_by{ |id, action| -action[:price] }.
        to_h
    end

    def my_spells
      @my_spells ||= actions.to_a.
        select{ |id, action| action_type(action) == "CAST" }.
        to_h
    end

    # @return [bool, bool, bool, bool]
    def givers_i_know
      givers_i_know ||= my_spells.select do |id, action|
        !action[1..4].find{ |v| v.negative? }
      end.each_with_object([false, false, false, false]) do |(id, giver), mem|
        mem[0] ||= giver[1].positive?
        mem[1] ||= giver[2].positive?
        mem[2] ||= giver[3].positive?
        mem[3] ||= giver[4].positive?
      end
    end

    def tomes
      @tomes ||= actions.to_a.
        select{ |id, action| action_type(action) == "LEARN" }.
        to_h
    end

    def opp_spells
    end

    # @potion [Hash] # {:delta0=>0, delta1:-2, delta2:0, delta3:0}
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

      return @spell_to_learn_id = nil if me[4] > 15

      # first pass, looking over up to fourth slot for pure giver spells
      spell_to_learn =
        tomes.find do |id, spell|
          spell[5] == 0 && pure_giver_spell?(spell)
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[5] == 1 && pure_giver_spell?(spell) && me[0..3][0] >= 1
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[5] == 2 && pure_giver_spell?(spell) && me[0..3][0] >= 2
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[5] == 3 && pure_giver_spell?(spell) && me[0..3][0] >= 3
        end

      # first candidate is free
      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[5] == 0 && !degeneration_spell?(spell)
        end

      # but subsequent need to consider tax
      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[5] == 1 && !degeneration_spell?(spell) && me[0..3][0] >= 1
        end

      spell_to_learn ||=
        tomes.find do |id, spell|
          spell[5] == 2 && !degeneration_spell?(spell) && me[0..3][0] >= 2
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
      whats_missing = inventory_delta(me[0..3], target_inventory)

      if whats_missing[3] > 0
        spells_for_getting_yellow =
          my_spells.select{ |id, spell| spell[4].positive? && spell[5] }

        castable_spell =
          spells_for_getting_yellow.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Yello for #{ target_inventory }" if castable_spell
      end

      if whats_missing[2] > 0 || (whats_missing[3] > 0 && me[0..3][2] == 0)
        spells_for_getting_orange =
          my_spells.select{ |id, spell| spell[3].positive? && spell[5] }

        castable_spell =
          spells_for_getting_orange.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Oranges for #{ target_inventory }" if castable_spell
      end

      if whats_missing[1] > 0 || ((whats_missing[2] > 0 || whats_missing[3] > 0) && me[0..3][1] == 0)
        spells_for_getting_green =
          begin
            my_spells.select{ |id, spell| spell[2].positive? && spell[5] }
          rescue => e
            debug my_spells
          end

        castable_spell =
          spells_for_getting_green.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Goo for #{ target_inventory }" if castable_spell
      end

      if (whats_missing[0] > 0 || (whats_missing[1] > 0 || whats_missing[2] > 0 || whats_missing[3] > 0) && me[0..3][0] == 0)
        spells_for_getting_blue =
          begin
            my_spells.select{ |id, spell| spell[1].positive? && spell[5] }
          rescue => e
            debug my_spells
          end

        castable_spell =
          spells_for_getting_blue.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Aqua for #{ target_inventory }" if castable_spell
      end

      "REST I'm beat while working towards #{ target_inventory }"
    end

    # @spell [Hash] # {:delta0=>0, delta1:-1, delta2:0, delta3:1, :castable=>true}
    # @return [Boolean]
    def i_can_cast?(spell)
      return false unless spell[5]

      GameSimulator.the_instance.can_cast?(
        operation: deltas(spell), from: me[0..3]
      )[:can]
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

    # @potion [Hash] # {:delta0=>0, delta1:-2, delta2:0, delta3:0}
    # @return [Boolean]
    def i_can_brew?(potion)
      deltas = deltas(potion)

      problems =
        (0..3).to_a.map do |i|
          next if (me[0..3][i] + deltas[i]) >= 0

          i
        end

      can = problems.compact.none?

      # debug("I can brew #{ potion }: #{ can }")

      can
    end
end

# game loop
@turn = 1
@previous_move = ""

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

    actions[action_id.to_i] =
      if action_type == "LEARN"
        # [type, (1..4)inv, 5=tome_index, 6=tax_bonus]
        [action_type, delta0.to_i, delta1.to_i, delta2.to_i, delta3.to_i, tome_index.to_i, tax_count.to_i]
      elsif action_type == "CAST"
        # [type, (1..4)inv, 5=castable, 6=repeatable]
        [action_type, delta0.to_i, delta1.to_i, delta2.to_i, delta3.to_i, castable.to_i == 1, repeatable.to_i == 1]
      else # as in BREW and OPP_CAST
        {
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
  end

  inv0, inv1, inv2, inv3, score = gets.split(" ").map(&:to_i)

  me = [
    inv0, inv1, inv2, inv3, #[0..3]
    score, # 4
    @turn, # 5
    @previous_move # 6
  ]

  inv0, inv1, inv2, inv3, score = gets.split(" ").map(&:to_i)

  opp = [
    inv0, inv1, inv2, inv3,
    score
  ]

  turn = GameTurn.new(
    actions: actions,
    me: me,
    opp: opp
  )

  # in the first league: BREW <id> | WAIT; later: BREW <id> | CAST <id> [<times>] | LEARN <id> | REST | WAIT
  # puts(@previous_move = turn.move)
  puts(@previous_move = turn.move_v2)
  @turn += 1
end

