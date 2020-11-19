class GameSimulator
  # This class provides methods to advance game state into the future to a certain degree
  # opponent moves can naturally not be simulated, and impossible to know what new spells
  # and potions will appear later.
  class ::SimulatorError < RuntimeError; end

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
    2 => {type:"CAST",:repeatable=>false, :delta0=>1, delta1:1, delta2:0, delta3:0, :castable=>true},
    3 => {type:"CAST",:repeatable=>false, :delta0=>0, delta1:0, delta2:1, delta3:0, :castable=>true},
    4 => {type:"CAST",:repeatable=>false, :delta0=>3, delta1:0, delta2:0, delta3:0, :castable=>true},
    12 => {type:"CAST",:repeatable=>false, :delta0=>2, delta1:1, delta2:0, delta3:0, :castable=>true},
    13 => {type:"CAST",:repeatable=>false, :delta0=>4, delta1:0, delta2:0, delta3:0, :castable=>true},
    14 => {type:"CAST",:repeatable=>false, :delta0=>0, delta1:0, delta2:0, delta3:1, :castable=>true},
    15 => {type:"CAST",:repeatable=>false, :delta0=>0, delta1:2, delta2:0, delta3:0, :castable=>true},
    16 => {type:"CAST",:repeatable=>false, :delta0=>1, delta1:0, delta2:1, delta3:0, :castable=>true},
    18 => {type:"CAST",:repeatable=>true, :delta0=>-1, delta1:-1, delta2:0, delta3:1, :castable=>true},
    17 => {type:"CAST",:repeatable=>true, :delta0=>-2, delta1:0, delta2:1, delta3:0, :castable=>true},
    38 => {type:"CAST",:repeatable=>true, :delta0=>-2, delta1:2, delta2:0, delta3:0, :castable=>true},
    39 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:0, delta2:-2, delta3:2, :castable=>true},
    40 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:-2, delta2:2, delta3:0, :castable=>true},
    30 => {type:"CAST",:repeatable=>true, :delta0=>-4, delta1:0, delta2:1, delta3:1, :castable=>true},
    34 => {type:"CAST",:repeatable=>true, :delta0=>-2, delta1:0, delta2:-1, delta3:2, :castable=>true},
    0 => {type:"CAST",:repeatable=>true, :delta0=>-3, delta1:0, delta2:0, delta3:1, :castable=>true},
    1 => {type:"CAST",:repeatable=>true, :delta0=>3, delta1:-1, delta2:0, delta3:0, :castable=>true},
    5 => {type:"CAST",:repeatable=>true, :delta0=>2, delta1:3, delta2:-2, delta3:0, :castable=>true},
    6 => {type:"CAST",:repeatable=>true, :delta0=>2, delta1:1, delta2:-2, delta3:1, :castable=>true},
    7 => {type:"CAST",:repeatable=>true, :delta0=>3, delta1:0, delta2:1, delta3:-1, :castable=>true},
    8 => {type:"CAST",:repeatable=>true, :delta0=>3, delta1:-2, delta2:1, delta3:0, :castable=>true},
    9 => {type:"CAST",:repeatable=>true, :delta0=>2, delta1:-3, delta2:2, delta3:0, :castable=>true},
    10 => {type:"CAST",:repeatable=>true, :delta0=>2, delta1:2, delta2:0, delta3:-1, :castable=>true},
    11 => {type:"CAST",:repeatable=>true, :delta0=>-4, delta1:0, delta2:2, delta3:0, :castable=>true},
    19 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:2, delta2:-1, delta3:0, :castable=>true},
    20 => {type:"CAST",:repeatable=>true, :delta0=>2, delta1:-2, delta2:0, delta3:1, :castable=>true},
    21 => {type:"CAST",:repeatable=>true, :delta0=>-3, delta1:1, delta2:1, delta3:0, :castable=>true},
    22 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:2, delta2:-2, delta3:1, :castable=>true},
    23 => {type:"CAST",:repeatable=>true, :delta0=>1, delta1:-3, delta2:1, delta3:1, :castable=>true},
    24 => {type:"CAST",:repeatable=>true, :delta0=>1, delta1:3, delta2:0, delta3:-1, :castable=>true},
    25 => {type:"CAST",:repeatable=>true, :delta0=>1, delta1:-3, delta2:0, delta3:2, :castable=>true},
    26 => {type:"CAST",:repeatable=>true, :delta0=>1, delta1:1, delta2:1, delta3:-1, :castable=>true},
    27 => {type:"CAST",:repeatable=>true, :delta0=>1, delta1:2, delta2:-1, delta3:0, :castable=>true},
    28 => {type:"CAST",:repeatable=>true, :delta0=>4, delta1:1, delta2:-1, delta3:0, :castable=>true},
    31 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:3, delta2:2, delta3:-2, :castable=>true},
    32 => {type:"CAST",:repeatable=>true, :delta0=>1, delta1:1, delta2:3, delta3:-2, :castable=>true},
    35 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:0, delta2:-3, delta3:3, :castable=>true},
    36 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:-3, delta2:3, delta3:0, :castable=>true},
    37 => {type:"CAST",:repeatable=>true, :delta0=>-3, delta1:3, delta2:0, delta3:0, :castable=>true},
    33 => {type:"CAST",:repeatable=>true, :delta0=>-5, delta1:0, delta2:3, delta3:0, :castable=>true},
    29 => {type:"CAST",:repeatable=>true, :delta0=>-5, delta1:0, delta2:0, delta3:2, :castable=>true},
    41 => {type:"CAST",:repeatable=>true, :delta0=>0, delta1:0, delta2:2, delta3:-1, :castable=>true},
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

  def self.the_instance
    @the_instance ||= new
  end

  def initialize; end

  # Returns the init parameters for the GameTurn that would follow after a certain move
  # Caches the outcomes, since same state and same move will always result in the same outcome
  #
  # @position [Hash] #
  # @return [Hash]
  def result(position:, move:)
    portions = move.split(" ")
    verb = portions.first #=> "LEARN", "REST", "CAST"

    case verb
    when "REST"
      if position.dig(:me, 6).to_s.start_with?("REST")
        raise SimulatorError.new("do not rest twice in a row!")
      end

      p = dup_of(position)

      p[:actions].transform_values! do |v|
        if action_type(v) == "CAST"
          v[:castable] = true
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
        raise SimulatorError.new("insufficient aqua for learning tax!")
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

      raise SimulatorError.new("spell exhausted!") unless cast_spell[:castable]

      cast_times =
        if portions.size > 2
          portions[2].to_i
        else
          1
        end

      if cast_times > 1 && !cast_spell[:repeatable]
        raise SimulatorError.new("spell can't multicast!")
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
          raise SimulatorError.new("insufficient ingredients for casting!") if cast_times == 1
          raise SimulatorError.new("insufficient ingredients for multicasting!")
        else
          raise SimulatorError.new("casting overfills inventory!")
        end
      end

      p = dup_of(position)

      cast_times.times do
        p[:me][0..3] = p[:me][0..3].add(deltas(cast_spell))
      end

      p[:actions][id][:castable] = false

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
    dupped_actions.transform_values!{ |v| v.dup }

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

  # This is the brute-forcing component.
  # Uses heuristics to try most promising paths first
  # @target [Array] # target inventory to solve for
  # @start [Hash] # the starting position, actions and me expected
  #
  # @return [Array<String>]
  def moves_towards(target:, start:, path: [], max_depth: 6, depth: 0)
    if depth == 0
      distance_from_target = distance_from_target(
        target: target, inv: start[:me][0..3]
      )

      return [] if distance_from_target[:distance].zero?

      # This cleans position passed on in hopes of saving on dup time, works well
      start[:actions] = start[:actions].select do |k, v|
        MY_MOVES.include?(action_type(v))
      end.to_h
    end

    positions = {
      path => start
    }

    (1..max_depth).to_a.each do |generation|
      debug("Starting move and outcome crunch for generation #{ generation }")
      debug("There are #{ positions.keys.size } positions to check moves for")

      final_iteration = generation == max_depth

      moves_to_try = []

      positions.each_pair do |path, position|
        moves = moves_from(position: position, skip_resting: final_iteration, skip_learning: final_iteration)
        # debug("There are #{ moves.size } moves that can be made after #{ path }")
        #=> ["REST", "CAST 79"]

        moves.each do |move|
          moves_to_try << [move, path]
        end
      end

      debug("There turned out to be #{ moves_to_try.size } moves to check")

      data =
        moves_to_try.each_with_object({}) do |(move, path), mem|
          # 2. loop over OK moves, get results
          outcome =
            begin
              result(position: positions[path], move: move)
            rescue SimulatorError => e
              next
            rescue => e
              raise("Path #{ path << move } leads to err: '#{ e.message }' in #{ e.backtrace.first }")
            end

          # 3. evaluate the outcome
          distance_from_target = distance_from_target(
            target: target, inv: outcome[:me][0..3]
          )

          key = [*path, move]

          mem[key] = {
            outcome: outcome,
            distance_from_target: distance_from_target
          }
        end

      sorted =
        data.sort_by do |(move, path), specifics|
          [
            specifics[:distance_from_target][:distance],
            -specifics[:distance_from_target][:bonus]
          ]
        end
      #=> [[move, data], ["CATS 78", {outcome: {actions: {...}}}]]

      prime_candidate = sorted.first
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
        return prime_candidate[0]
      end

      # no move got us there, lets go deeper
      # 3. Loop over results with 1. again.
      # Can use heuristics:
      # - try promising outcomes first (DONE)
      # - drop exceptionally poor variants that have no hope of catching up
      positions = {}

      sorted.each do |path, specifics|
        positions[path] = specifics[:outcome]
      end
    end
  end

  # This is the evaluator method.
  # every ingredient that is missing from target is taken to be a distance of [1,2,3,4] respectively
  # ingredients that are more do not reduce distance, but are counted as a bonus
  #
  # @return [Hash]
  def distance_from_target(target:, inv:)
    # @distance_cache ||= {}
    # key = [target, inv]

    # if @distance_cache.key?(key)
    #   @distance_cache[key]
    # else
    #   sum = target.add(inv.map{|v| -v})
    #   distance = sum.map.with_index{ |v, i| next unless v.positive?; v*i.next }.compact.sum
    #   bonus = sum.map.with_index{ |v, i| next unless v.negative?; -v*i.next }.compact.sum

    #   @distance_cache[key] = {distance: distance, bonus: bonus}
    # end
    sum = target.add(inv.map{|v| -v})
    distance = sum.map.with_index{ |v, i| next unless v.positive?; v*i.next }.compact.sum
    bonus = sum.map.with_index{ |v, i| next unless v.negative?; -v*i.next }.compact.sum
    {distance: distance, bonus: bonus}
  end

  # Does not care about legality much, since simulator will check when deciding outcome.
  # @return [Array<String>]
  def moves_from(position:, skip_resting: false, skip_learning: false)
    moves = []

    position[:actions].each do |id, action|
      type = action_type(action)

      if type == "LEARN" && !skip_learning
        moves << "LEARN #{ id }"
      elsif type == "CAST"
        times = possible_cast_times(spell: action, inv: position[:me][0..3])

        next if times == 0

        times.times do |i|
          if i == 0
            moves << "CAST #{ id }"
          else
            moves << "CAST #{ id } #{ i.next }"
          end
        end
      end
    end

    if !skip_resting && !position[:me][6].to_s.start_with?("REST")
      moves << "REST"
    end

    moves
  end

  # Returns ways can this spell can be cast in. 0, 1 or n(multicast) variants possible.
  # @return [Integer] # number of times the spell can be cast from this inventory
  def possible_cast_times(spell:, inv:)
    # @cast_time_cache ||= {}
    # key = [spell, inv]

    # if @cast_time_cache.key?(key)
    #   @cast_time_cache[key]
    # else
    #   return @cast_time_cache[key] = 0 unless spell[:castable]

    #   deltas = deltas(spell)

    #   can_cast_once = can_cast?(operation: deltas, from: inv)

    #   return @cast_time_cache[key] = 0 unless can_cast_once[:can]

    #   # here we know that can be cast at least once
    #   return @cast_time_cache[key] = 1 unless spell[:repeatable]

    #   # here we know the spell can be repeated
    #   (2..5).to_a.each do |i|
    #     next if can_cast?(operation: deltas.map{ |v| v * i}, from: inv)[:can]

    #     return @cast_time_cache[key] = i-1
    #   end

    #   return @cast_time_cache[key] = 5
    # end

    return 0 unless spell[:castable]

    deltas = deltas(spell)

    can_cast_once = can_cast?(operation: deltas, from: inv)

    return 0 unless can_cast_once[:can]

    # here we know that can be cast at least once
    return 1 unless spell[:repeatable]

    # here we know the spell can be repeated
    (2..5).to_a.each do |i|
      next if can_cast?(operation: deltas.map{ |v| v * i}, from: inv)[:can]

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
