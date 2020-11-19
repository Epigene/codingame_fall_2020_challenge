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
      leftmost_potion_with_bonus = potions.find{ |id, potion| potion[:tome_index] == 3 }
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
        me: me,
        meta: meta
      }
    end

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

    # @spell [Hash] # {:delta0=>0, delta1:-1, delta2:0, delta3:1, :castable=>true}
    # @return [Boolean]
    def i_can_cast?(spell)
      return false unless spell[:castable]

      GameSimulator.the_instance.can_cast?(
        operation: deltas(spell), from: me[:inv]
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
