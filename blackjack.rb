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
  cards_noace = cards.select { |c| c[1] != 'A' }

  val_noace = sum_noace(cards_noace)

  return val_noace if cards_ace.size == 0

  ace_sums = calculate_ace_sum(cards_ace.size)

  sums = []
  ace_sums.each { |x| sums << x + val_noace }

  arr_21 = sums.select { |x| x == 21 }
  return 21 if arr_21.size > 0

  return 22 if sums.first > 21

  arr_20 = sums.select { |x| x < 21 }
  arr_20.last
end

# Array -> Integer
# return value(2-10) for a card(2-K)
# e.g. ['D', '2'] should return 2, ['D', 'J'] return 10
def calculate_value(card)
  # card example: ['C', '2']
  s = card[1]
  return 10 if %w(10 J Q K).include?(s)
  return s.to_i if %w(2 3 4 5 6 7 8 9).include?(s)
end

assert_equal(2, calculate_value(%w(S 2)))
assert_equal(9, calculate_value(%w(S 9)))
assert_equal(10, calculate_value(%w(S 10)))
assert_equal(10, calculate_value(%w(S J)))

# Array -> Integer
# produce sum of all cards in the array
def sum_noace(cards)
  sum = 0
  cards.each { |c| sum += calculate_value(c) }
  sum
end

assert_equal(10, sum_noace([['D', '10']]))
assert_equal(14, sum_noace([['D', '10'], ['S', '4']]))
assert_equal(21, sum_noace([['D', '2'], ['D', '9'], ['S', 'K']]))

# Integer -> Array
# asume n >= 1,produce array of uniq combination ace sum for n aces
# every ace value can be 1 or 11
def calculate_ace_sum(n)
  vals = []
  n.times do |n|
    vals << 1
    vals << 11
  end

  arr = vals.combination(n).to_a

  arr2 = []

  arr.each do |item|
    sum = 0
    item.each { |i| sum += i }
    arr2 << sum
  end

  arr2.uniq!
  arr2.sort!
  arr2
end

assert_equal([1, 11], calculate_ace_sum(1))
assert_equal([2, 12, 22], calculate_ace_sum(2))
assert_equal([3, 13, 23, 33], calculate_ace_sum(3))
assert_equal([4, 14, 24, 34, 44], calculate_ace_sum(4))

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
    # break
  end

  if mytotal > 21
    puts "You have: #{ mycards.inspect } " \
    "for a total of: #{ mytotal }"
    puts 'Burst! You lose!'
    exit
    # break
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
