# game loop
loop do
  action_count = gets.to_i # the number of spells and recipes in play

  actions = {}

  action_count.times do
    # action_id: the unique ID of this spell or recipe
    # action_type: in the first league: BREW; later: CAST, OPPONENT_CAST, LEARN, BREW
    # delta_0: tier-0 ingredient change
    # delta_1: tier-1 ingredient change
    # delta_2: tier-2 ingredient change
    # delta_3: tier-3 ingredient change
    # price: the price in rupees if this is a potion
    # tome_index: in the first two leagues: always 0; later: the index in the tome if this is a tome spell, equal to the read-ahead tax; For brews, this is the value of the current urgency bonus
    # tax_count: in the first two leagues: always 0; later: the amount of taxed tier-0 ingredients you gain from learning this spell; For brews, this is how many times you can still gain an urgency bonus
    # castable: in the first league: always 0; later: 1 if this is a castable player spell
    # repeatable: for the first two leagues: always 0; later: 1 if this is a repeatable player spell
    action_id, action_type, delta_0, delta_1, delta_2, delta_3, price, tome_index, tax_count, castable, repeatable = gets.split(" ")
    action_id = action_id.to_i

    actions[action_id.to_i] = {
      delta_0: delta_0.to_i,
      delta_1: delta_1.to_i,
      delta_2: delta_2.to_i,
      delta_3: delta_3.to_i,
      price: price.to_i,
      tome_index: tome_index.to_i,
      tax_count: tax_count.to_i,
      castable: castable.to_i == 1,
      repeatable: repeatable.to_i == 1
    }
  end

  inv_0, inv_1, inv_2, inv_3, score = gets.split(" ").map(&:to_i)

  me = {
    inv_0: inv_0,
    inv_1: inv_1,
    inv_2: inv_2,
    inv_3: inv_3,
    score: score
  }

  inv_0, inv_1, inv_2, inv_3, score = gets.split(" ").map(&:to_i)

  opp = {
    inv_0: inv_0,
    inv_1: inv_1,
    inv_2: inv_2,
    inv_3: inv_3,
    score: score
  }

  turn = GameTurn.new(
    actions: actions,
    me: me,
    opp: opp
  )

  # in the first league: BREW <id> | WAIT; later: BREW <id> | CAST <id> [<times>] | LEARN <id> | REST | WAIT
  puts turn.move
end
