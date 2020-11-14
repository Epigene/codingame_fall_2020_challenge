class GameTurn
  # Given wood 2 spells, ingredient relative costs
  COSTS = {
    delta0: 1,
    delta1: 3,
    delta2: 5,
    delta3: 7
  }.freeze

  attr_reader :actions, :me, :opp, :meta

  def initialize(actions:, me:, opp:, meta: {turn: 1})
    actions.each do |k, v|
      debug("#{ k } => #{ v }", prefix: "")
    end
    @actions = actions

    @me = me
    @opp = opp

    debug("me: #{ me }")
    debug("opp: #{ opp }")

    @meta = meta
    debug("meta: #{ meta }")
  end

  # The only public API, returns the preferable move string
  def move
    brewable_potion = potions.find { |id, potion| i_can_brew?(potion) }

    unless brewable_potion.nil?
      return "BREW #{ brewable_potion[0] }"
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

    # @return [Integer, nil]
    def spell_to_learn_id
      return @spell_to_learn_id if defined?(@spell_to_learn_id)

      return @spell_to_learn_id = nil if meta[:turn] > 20

      @spell_to_learn_id = tomes.find{ |id, data| data[:tome_index] == 0 }[0]
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

        return "CAST #{ castable_spell[0] } Yello!" if castable_spell
      end

      if whats_missing[2] > 0 || (whats_missing[3] > 0 && me[:inv][2] == 0)
        spells_for_getting_orange =
          my_spells.select{ |id, spell| spell[:delta2].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_orange.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Oranges!" if castable_spell
      end

      if whats_missing[1] > 0 || ((whats_missing[2] > 0 || whats_missing[3] > 0) && me[:inv][1] == 0)
        spells_for_getting_green =
          my_spells.select{ |id, spell| spell[:delta1].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_green.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Goo!" if castable_spell
      end

      if (whats_missing[0] > 0 || (whats_missing[1] > 0 || whats_missing[2] > 0 || whats_missing[3] > 0) && me[:inv][0] == 0)
        spells_for_getting_blue =
          my_spells.select{ |id, spell| spell[:delta0].positive? && spell[:castable] }

        castable_spell =
          spells_for_getting_blue.find do |id, spell|
            i_can_cast?(spell)
          end

        return "CAST #{ castable_spell[0] } Aqua!" if castable_spell
      end

      "REST I'm beat!"
    end

    # @spell [Hash] # {:delta0=>0, :delta1=>-1, :delta2=>0, :delta3=>1, :castable=>true}
    # @return [Boolean]
    def i_can_cast?(spell)
      return false unless spell[:castable]

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
