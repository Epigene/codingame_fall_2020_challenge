class GameTurn
  attr_reader :actions, :me, :opp

  def initialize(actions:, me:, opp:)
    debug("actions:")
    actions.each do |k, v|
      debug("#{ k }: #{ v }")
    end
    @actions = actions

    @me = me
    @opp = opp

    debug("me: #{ me }")
    debug("opp: #{ opp }")
  end

  # The only public API, returns the preferable move string
  def move
    brewable_potion = potions.find { |id, potion| i_can_brew?(potion) }

    unless brewable_potion.nil?
      return "BREW #{ brewable_potion[0] }"
    end

    "WAIT"
  end

  private

    # Just potion actions (have price), sorted descending by price
    #
    # @return [Hash]
    def potions
      actions.to_a.
        select{ |id, data| data[:price].to_i.positive? }.
        sort_by{ |id, data| -data[:price] }.
        to_h
    end

    # @potion [Hash] # {:delta_0=>0, :delta_1=>-2, :delta_2=>0, :delta_3=>0}
    # @return [Boolean]
    def i_can_brew?(potion)
      problems =
        (0..3).to_a.map do |i|
          next if (me["inv_#{ i }".to_sym] + potion["delta_#{ i }".to_sym]) >= 0

          i
        end

      can = problems.compact.none?

      debug("I can brew #{ potion }: #{ can }")

      can
    end
end
