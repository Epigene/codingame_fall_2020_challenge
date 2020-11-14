require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

def debug(message, prefix: "=> ")
  STDERR.puts("#{ prefix }#{ message }")
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
    # actions.each do |k, v|
    #   debug("#{ k } => #{ v }", prefix: "")
    # end
    @actions = actions

    @me = me
    @opp = opp

    # debug("me: #{ me }")
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

