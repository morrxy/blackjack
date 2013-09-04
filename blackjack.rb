require 'test/unit'
include Test::Unit::Assertions

def play_game(player_name)
  puts "#{ '=' * 40 }"
  puts "Hi #{ player_name }! Welcome Blackjack!"

  deck = new_deck
  mycards = []
  dealercards = []
  deal(deck, mycards, dealercards)

  mytotal = calculate_total(mycards)
  dealertotal = calculate_total(dealercards)

  if mytotal == 21 && dealertotal < 21
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts "Blackjack! #{player_name} win!"
    return
  end

  if mytotal == 21 && dealertotal == mytotal
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts 'draw game'
    return
  end

  mytotal = player_turn(deck, mycards, mytotal, dealercards, dealertotal, player_name)

  if mytotal == 21
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts "Blackjack! #{player_name} win!"
    return
  end

  if mytotal > 21
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts "burst! #{ player_name } lose"
    return
  end

  dealertotal = dealer_turn(deck, mycards, mytotal, dealercards, dealertotal, player_name)

  if dealertotal > 21
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts "dealer burst! #{ player_name } win"
    return
  end

  report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
  if mytotal > dealertotal
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts "#{ player_name } win"
  elsif mytotal < dealertotal
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts 'Dealer win'
  else
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts 'draw game'
  end
end

def report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
  puts
  puts "dealer's cards: #{ dealercards.inspect }"
  puts "dealer's total: #{ dealertotal }"
  puts "#{ player_name }'s cards: #{ mycards.inspect }"
  puts "#{ player_name }'s total: #{ mytotal }"
  puts
end

def new_deck
  suits = %w(H D S C)
  cards = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  deck = suits.product(cards)
  deck.shuffle!
end

def deal(deck, mycards, dealercards)
  mycards << deck.pop
  dealercards << deck.pop
  mycards << deck.pop
  dealercards << deck.pop
end

# produce new mytotal,22 or 21 or <21
def player_turn(deck, mycards, mytotal, dealercards, dealertotal, player_name)

  while true
    report(deck, mycards, mytotal, dealercards, dealertotal, player_name)
    puts 'What would you like to do? 1) hit 2) stay'
    hit_or_stay = gets.chomp
    unless %w(1 2).include?(hit_or_stay)
      puts 'What would you like to do? 1) hit 2) stay'
      next
    end

    break if hit_or_stay == '2'

    mycards << deck.pop
    mytotal = calculate_total(mycards)
    return 21 if mytotal == 21
    return 22 if mytotal > 21
  end

  mytotal
end

def dealer_turn(deck, mycards, mytotal, dealercards, dealertotal, player_name)
  while true
    break if dealertotal >= 17 && dealertotal > mytotal
    dealercards << deck.pop
    # puts "decksize:#{ deck.size }"
    dealertotal = calculate_total(dealercards)
  end
  dealertotal
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

# unit test start
assert_equal(2, calculate_value(%w(S 2)))
assert_equal(9, calculate_value(%w(S 9)))
assert_equal(10, calculate_value(%w(S 10)))
assert_equal(10, calculate_value(%w(S J)))

assert_equal(10, sum_2_to_k([%w(D 10)]))
assert_equal(14, sum_2_to_k([%w(D 10), %w(S 4)]))
assert_equal(21, sum_2_to_k([%w(D 2), %w(D 9), %w(S K)]))

assert_equal([1, 11], make_aces(1))
assert_equal([1, 11, 1, 11], make_aces(2))
assert_equal([1, 11, 1, 11, 1, 11], make_aces(3))
assert_equal([1, 11, 1, 11, 1, 11, 1, 11], make_aces(4))

assert_equal([8, 9], calculate_ace_sets([[8], [9]]))
assert_equal([5, 16], calculate_ace_sets([[2, 3], [6, 10]]))
assert_equal([11, 23], calculate_ace_sets([[2, 3, 6], [6, 7, 10]]))

assert_equal([1, 11], make_ace_vals(1))
assert_equal([2, 12, 22], make_ace_vals(2))
assert_equal([3, 13, 23, 33], make_ace_vals(3))
assert_equal([4, 14, 24, 34, 44], make_ace_vals(4))

assert_equal([4, 14], make_total_vals(3, 1))
assert_equal([6, 16, 26], make_total_vals(4, 2))
assert_equal([5, 15, 25, 35], make_total_vals(2, 3))

# main progress start
puts 'What\'s your name?'
player_name = gets.chomp

play_game(player_name)

while true
  puts "\nplay again? 1)Yes 2)No"
  again = gets.chomp
  next unless %w(1 2).include?(again)
  break if again == '2'
  play_game(player_name) if again == '1'
end
