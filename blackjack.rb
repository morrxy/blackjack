# encoding: UTF-8
#
# Blackjack is a card game where you calculate the sum of the values of your
# cards and try to hit 21, aka "blackjack". Both the player and dealer are
# dealt two cards to start the game. All face cards are worth whatever
# numerical value they show. Suit cards are worth 10. Aces can be worth either
# 11 or 1. Example: if you have a Jack and an Ace, then you have hit
# "blackjack", as it adds up to 21.
#
# After being dealt the initial 2 cards, the player goes first and can choose
# to either "hit" or "stay". Hitting means deal another card. If the player's
# cards sum up to be greater than 21, the player has "busted" and lost. If the
# sum is 21, then the player wins. If the sum is less than 21, then the player
# can choose to "hit" or "stay" again. If the player "hits", then repeat above,
# but if the player stays, then the player's total value is saved, and the turn
# moves to the dealer.
#
# By rule, the dealer must hit until she has at least 17. If the dealer busts,
# then the player wins. If the dealer, hits 21, then the dealer wins. If,
# however, the dealer stays, then we compare the sums of the two hands between
# the player and dealer; higher value wins.

require 'test/unit'
include Test::Unit::Assertions

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

puts 'welcome to blackjack!'

suits = %w(H D S C)
cards = %w(2 3 4 5 6 7 8 9 10 J Q K A)

deck = suits.product(cards)
deck.shuffle!

# Deal Cards

mycards = []
dealercards = []

mycards << deck.pop
dealercards << deck.pop
mycards << deck.pop
dealercards << deck.pop

dealertotal = calculate_total(dealercards)
mytotal = calculate_total(mycards)

def ask_player(dealercards, mycards, dealertotal, mytotal)
  puts "Dealer has: #{ dealercards.inspect } " \
  "for a total of: #{ dealertotal }"
  puts "You have: #{ mycards.inspect } " \
  "for a total of: #{ mytotal }"
  puts ''
  puts 'What would you like to do? 1) hit 2) stay'
end

ask_player(dealercards, mycards, dealertotal, mytotal)

while true
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
    exit
  end

  if mytotal > 21
    puts "You have: #{ mycards.inspect } " \
    "for a total of: #{ mytotal }"
    puts 'Burst! You lose!'
    exit
  end

  ask_player(dealercards, mycards, dealertotal, mytotal)
end

while true
  break if dealertotal >= 17 && dealertotal > mytotal
  dealercards << deck.pop
  dealertotal = calculate_total(dealercards)
end

puts "Dealer has: #{ dealercards.inspect } " \
"for a total of: #{ dealertotal }"

if dealertotal == 21
  puts 'Blackjack! Dealer win!'
  exit
end

if dealertotal > 21
  puts 'Dealer burst! You win!'
  exit
end

if mytotal > dealertotal
  puts 'You win'
elsif mytotal < dealertotal
  puts 'You lose'
else
  puts 'draw game'
end
