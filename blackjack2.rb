def play_game
  deck = new_deck
  puts "decksize:#{ deck.size }"

  mycards = []
  dealercards = []
  deal(deck, mycards, dealercards)
  puts "my:#{ mycards.inspect } dealer:#{ dealercards.inspect }"
  puts "decksize:#{ deck.size }"

  mytotal = calculate_total(mycards)
  dealertotal = calculate_total(dealercards)
  puts "detotal:#{ dealertotal } mytotal:#{ mytotal }"

  if dealertotal == mytotal && mytotal == 21
    puts 'draw game'
    return
  end

  mytotal = player_turn(deck, mycards, mytotal, dealertotal)

  dealertotal = dealer_turn(deck, mycards, mytotal, dealertotal)
end

def new_deck
  suits = %w(H D S C)
  cards = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  deck = suits.product(cards)
  deck.shuffle!
end

def deal(deck, mycards, dealercards)
  puts 'dealing'
  mycards << deck.pop
  dealercards << deck.pop
  mycards << deck.pop
  dealercards << deck.pop
end

def player_turn(deck, mycards, mytotal, dealertotal)

  while true
    puts 'What would you like to do? 1) hit 2) stay'
    hit_or_stay = gets.chomp
    unless %w(1 2).include?(hit_or_stay)
      puts 'What would you like to do? 1) hit 2) stay'
      next
    end

    break if hit_or_stay == '2'

    mycards << deck.pop
    mytotal = calculate_total(mycards)

    if mytotal == 21
      puts "You have: #{ mycards.inspect } " \
      "for a total of: #{ mytotal }"
      puts 'Blackjack! You win!'
      return 21
    end

    if mytotal > 21
      puts "You have: #{ mycards.inspect } " \
      "for a total of: #{ mytotal }"
      puts 'Burst! You lose!'
      return 22
    end

  end

end

# !!!
def dealer_turn(deck, mycards, mytotal, dealertotal)
  puts 'dealer turn'
  while true
    break if dealertotal >= 17 && dealertotal > mytotal
    dealercards << deck.pop
    dealertotal = calculate_total(dealercards)
  end
end

def calculate_total(cards)
  cards_ace = cards.select { |c| c[1] == 'A' }
  cards_2_to_k = cards.select { |c| c[1] != 'A' }

  val_2_to_k = sum_2_to_k(cards_2_to_k)
  return val_2_to_k if cards_ace.size == 0

  # all posible uniq sorted total value
  total_vals = make_total_vals(val_2_to_k, cards_ace.size)

  return 22 if total_vals.first > 21

  vals_21 = total_vals.select { |v| v == 21 }
  return 21 if vals_21.size > 0

  vals_20 = total_vals.select { |v| v < 21 }
  vals_20.last
end

# Array -> Integer
# produce sum of all cards in the array
def sum_2_to_k(cards)
  sum = 0
  cards.each { |c| sum += calculate_value(c) }
  sum
end

# Array -> Integer
# return value(2-10) for a card(2-K)
# e.g. ['D', '2'] should return 2, ['D', 'J'] return 10
def calculate_value(card)
  s = card[1]
  return 10 if %w(10 J Q K).include?(s)
  return s.to_i if %w(2 3 4 5 6 7 8 9).include?(s)
end

# Integer -> Array of Integer
# produce array of all posible total value for 1 val plus
# each combination n ace, ace can be 1 or 11
def make_total_vals(val, n)
  ace_vals = make_ace_vals(n)
  total_vals = []
  ace_vals.each { |x| total_vals << x + val }
  total_vals
end

# Integer -> Array
# asume n >= 1, produce array of uniq combination ace sum for n aces
# every ace value can be 1 or 11
def make_ace_vals(n)
  aces = make_aces(n)
  ace_sets = aces.combination(n).to_a

  ace_vals = calculate_ace_sets(ace_sets)
  ace_vals.uniq!
  ace_vals.sort!
end

# Integer -> Array of integer
# produce array of all n ace value, ace can be 1 or 11
# e.g. for 1 ace [1, 11] for 2 ace [1, 11, 1, 11]
def make_aces(n)
  ace_vals = []
  n.times do
    ace_vals << 1
    ace_vals << 11
  end
  ace_vals
end

# Array of array of Integer -> Array of integer
# produce an array for each given array's array item's sum
def calculate_ace_sets(arr)
  result = []

  arr.each do |item|
    sum = 0
    item.each { |i| sum += i }
    result << sum
  end

  result
end

puts 'Welcome Blackjack! What\'s your name?'
player_name = gets.chomp

play_game

while true
  puts 'play again? y)Yes n)No'
  play_again = gets.chomp
  next unless %w(y n).include?(play_again.downcase)
  break if play_again.downcase == 'n'
  play_game if play_again.downcase == 'y'
end
