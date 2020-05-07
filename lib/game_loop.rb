loop do
  x, y, my_life, opp_life, torpedo_cooldown, sonar_cooldown, silence_cooldown, mine_cooldown = gets.split(" ").map(&:to_i)

  sonar_result = gets.chomp
  opponent_orders = gets.chomp

  puts captain.orders(
    x, y,
    my_life, opp_life,
    torpedo_cooldown, sonar_cooldown, silence_cooldown, mine_cooldown,
    sonar_result,
    opponent_orders
  )
end
