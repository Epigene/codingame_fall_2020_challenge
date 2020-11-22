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
      brewable_potion = potions.find { |_id, potion| i_can_brew?(potion) }

      if brewable_potion
        return "BREW #{ brewable_potion[0] } Brewin' #{ brewable_potion[0] }"
      end

      if me[5] < 10 # before 10th turn
        closest_pure_giver_spell =
          tomes.find do |id, _tome|
            GameSimulator::PURE_GIVER_IDS.include?(id)
          end
        #=> [id, tome]

        #                              never learn pure givers in 6th tome spot, too expensive
        if closest_pure_giver_spell && closest_pure_giver_spell[1][5] < 5
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

      if me[5] < 4 # before 4th turn
        closest_very_good_spell =
          tomes.find do |id, _tome|
            GameSimulator::INSTALEARN_NET_FOUR_SPELLS.include?(id)
          end

        if closest_very_good_spell && closest_very_good_spell[1][5] <= me[0]
          return "LEARN #{ closest_very_good_spell[0] } this one's a keeper!"
        end
      end

      # if me[5] <= 4 # up to move 4, simply learning spells that give 2 or more net aqua
      if me[5] <= 4 || gross_value(opp) < 5 # if opp is focused on learning also and has low value
        lucrative_to_learn = GameSimulator.the_instance.
          net_aqua_gains_from_learning(aquas_on_hand: me[0], tomes: tomes).
          max_by{ |_id, gain| gain }

        if lucrative_to_learn && lucrative_to_learn[1] >= 2
          return "LEARN #{ lucrative_to_learn[0] } good Aqua gain from learning"
        end
      end

      # let's see if I don't need transmuters for imba aqua givers
      if me[5] <= 6
        i_have_enhanced_givers = my_spells.find do |id, spell|
          deltas = spell[1..4]

          GameSimulator::ENHANCED_AQUA_GIVERS.find {|id| GameSimulator::LEARNABLE_SPELLS[id][0..3] == deltas }
        end

        if i_have_enhanced_givers
          i_have_enhanced_transmuters = my_spells.find do |id, spell|
            deltas = spell[1..4]

            GameSimulator::ENHANCED_AQUA_TRANSMUTERS.find { |id| GameSimulator::LEARNABLE_SPELLS[id][0..3] == deltas }
          end

          unless i_have_enhanced_transmuters
            good_transmuter = tomes.find.with_index do |(id, tome), i|
              i <= 1 && GameSimulator::ENHANCED_AQUA_TRANSMUTERS.include?(id) && tome[5] <= me[0]
            end

            if good_transmuter
              return "LEARN #{ good_transmuter[0] } learning a good transmuter to get rid of aquas"
            end
          end
        end
      end

      # casting [2,0,0,0] in the first few rounds if no learning has come up (yet)
      if me[1] < 5 && (me[5] <= 4 || gross_value(opp) < 5) # if opp is focused on learning also and has low value
        best_aqua_giver = my_spells.select do |id, spell|
          # pure aqua giver
          spell[1].positive? && spell[2].zero? && spell[3].zero? && spell[4].zero? &&
            # can be cast
            spell[5]
        end.max_by{|_id, spell| spell[1] }

        if best_aqua_giver
          return "CAST #{ best_aqua_giver[0] } stockpiling Aquas early in the game"
        end
      end

      # if me[5] < 4 # before 4th turn, hardcoded learning
      #   # identify 3rd spell as very good, by starting with Yello, down to Aqua, checking if I have giver

      #   # determine that [2, 0, 0, 0] is the state to learn it
      #   # run bruteforcer for that, make sure it returns learning

      #   closest_tactical_transmuter =
      #     tomes.find do |id, tome|
      #       next unless GameSimulator::TACTICAL_DEGENERATORS.include?(id)

      #       _i_have_a_givers_for_what_this_spell_takes =
      #         if tome[3].negative?
      #           givers_i_know[2]
      #         elsif tome[4].negative?
      #           givers_i_know[3]
      #         end
      #     end

      #   if closest_tactical_transmuter
      #     tax_for_transmuter = [closest_tactical_transmuter[1][5], 0].max

      #     the_moves = GameSimulator.the_instance.moves_towards(
      #       start: position, target: [tax_for_transmuter, 0, 0, 0]
      #     )

      #     move =
      #       if the_moves == []
      #         # oh, already there, let's learn
      #         "LEARN #{ closest_tactical_transmuter[0] }"
      #       else
      #         "#{ the_moves.first } let's try learning #{ closest_tactical_transmuter[0] } via [#{ the_moves.join(", ") }]"
      #       end

      #     return move
      #   end
      # end

      # if me[5] < 4 && givers_i_know[1] # i know green givers
      #   # identify tactical advantage in learning a green transmuter

      #   closest_green_user =
      #     tomes.find do |id, tome|
      #       next if id == 1 # LEARN 1 is very bad

      #       tome[2].negative? && tome[5] <= me[0]
      #     end

      #   if closest_green_user
      #     return "LEARN #{ closest_green_user[0] } learning useful transmuter that uses green"
      #   end

      #   # if I have green givers and the spell takes greens (an is not LEARN 1)
      # end

      leftmost_potion_with_bonus =
        potions.find { |id, potion| potion[:tome_index] == 3 }
      #[id, potion]

      potion_to_work_towards =
        if leftmost_potion_with_bonus
          leftmost_potion_with_bonus
        else
          # [simplest_potion_id, potions[simplest_potion_id]]
          most_lucrative_potion
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

    debug("finding move_v2 '#{ move }' took #{ (elapsed * 1000.0).round }ms")

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

    # @player [Array] :me or :opp array
    # @return [Integer] 1 for any aqua 2 for green etc + worth from potions
    def gross_value(player)
      player[0] + player[1]*2 + player[2]*3 + player[3]*4 + player[4]
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

    def most_lucrative_potion
      return @most_lucrative_potion if defined?(@most_lucrative_potion)

      @most_lucrative_potion = potions.max_by{ |_id, potion| potion[:price] }
    end

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
