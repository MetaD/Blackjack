require_relative 'card'
require_relative 'deck'
require_relative 'hand'
require_relative 'player'

MIN_BET = 5

# Reads a positive integer from input
def read_valid_int(msg)
  result = 0
  loop do
    print msg
    result = Float(gets) rescue nil
    yield(result) ?
        break : (puts 'Invalid number!')
  end
  result
end


# Reads a valid string from input
def read_valid_string(msg, err_msg)
  str = ''
  loop do
    print msg
    str = gets.chomp
    yield(str) ? break : (puts err_msg)
  end
  str
end


# Asks the user whether to start a new round
def start_new_round
  loop do
    puts 'Would you like to start a new round? (Y/N)'
    answer = gets.chomp
    return true if answer == 'Y' || answer == 'y'
    return false if answer == 'N' || answer == 'n'
  end
end



# START GAME
# Initialize players
num_players = read_valid_int('Number of players: ') {|i| (i && i > 0)}  # must be positive
players = []
(1..num_players).each { |i|
  name = read_valid_string(
      "Please enter the name of player #{i}: ",
      'Please enter a valid name!'
  ) { |name| name == name[/[a-zA-Z0-9]+/] && name != 'Dealer' }
  # A valid name must contain only letters and numbers, and cannot be "Dealer"

  players << Player.new(name)
}

# Initialize the deck
deck = Deck.new
#60.times { puts deck.deal }

# START PLAYING
while true
  dealer = Player.new('Dealer')

  # remove those players without enough money
  players.delete_if do |p|
    if p.money < MIN_BET
      puts "Player #{p.name} does not have enough money"
      num_players -= 1
    end
    p.money < MIN_BET
  end

  # no player has enough money - end of game
  if num_players == 0
    puts 'All players have run out of money!'
    break
  end

  # bet
  players.each do |p|
    # amount must be > MIN_BET and <= the money that player has
    amount = read_valid_int("Player #{p.name} ($#{p.money}) bets (minimum $#{MIN_BET}): ") do |i|
      (i && i >= MIN_BET && i <= p.money)
    end
    p.bet(0, amount)
  end

  # deal two cards to the dealer
  dealer.add_card(deck.deal, true) # only the first card is visible
  dealer.add_card(deck.deal, false)

  # deal two cards to each player
  players.each do |p|
    next if p.round_ended
    2.times { p.add_card(deck.deal, true) } # add and announce
  end

  # Players act: hit/stand/double/split
  players.each do |p|
    next if p.round_ended

    p.print_info
    p.hands.each_with_index do |h, h_i|
      loop do
        break if h.value > 21 || h.has_21
        action = read_valid_string(
            "Player #{p.name}, please enter hit/stand/double/split" +
                (p.hands.size == 1 ? ': ' : " for your hand ##{h_i+1}: "),
            'Action not available!'
        ) { |act| act == 'hit' || act == 'stand' ||
            (act == 'double' && p.money >= h.bet) ||
            (act == 'split' && h.can_split && p.money >= h.bet) }

        case action
          when 'hit'
            p.add_card(deck.deal, h_i, true)
            p.print_info
          when 'stand'
            break # continue to next hand/player
          when 'double'
            p.bet(h_i, h.bet)
            p.add_card(deck.deal, h_i, true)
            p.print_info
            break # continue to next hand/player
          when 'split'
            p.add_hand(h.split)
            # deal one card to each splitted hand
            p.add_card(deck.deal, h_i, true)
            p.add_card(deck.deal, p.hands.size - 1, true)
            p.print_info
          else
        end # end of action
      end # end of one hand
    end # end of hands
  end # end of players

  # Dealer acts
  dealer.print_info # Dealer shows both cards
  # check for dealer's natural 21
  dealer_natural_21 = dealer.hands[0].has_21 ? true : false
  if dealer_natural_21
    puts 'Dealer has a blackjack!'
  else  # continue to deal cards (or stand)
    while dealer.hands[0].value < 7 ||
        (!dealer.hands[0].soft && dealer.hands[0].value < 17)
      dealer.add_card(deck.deal, true)
    end
    puts 'Dealer stands' if dealer.hands[0].value < 21
    dealer.print_info
  end

  # compare results
  players.each do |p|
    p.hands.each_with_index do |h, h_i|
      if h.value > 21 # player busted
        p.lose(h_i)
        next
      end
      dealer_value = dealer.hands[0].value
      dealer_value += 10 if dealer.hands[0].soft && dealer_value < 12
      if dealer_value > 21 # dealer busted
        # everyone not busted wins
        p.natural_21 ? p.win(h_i, 1.5) : p.win(h_i, 1)
      elsif dealer_natural_21
        p.natural_21 ? p.push(h_i) : p.lose(h_i)
      else # dealer's value <= 21 and is not natural 21
        player_value = h.value
        player_value += 10 if h.soft && player_value < 12
        if dealer_value > player_value
          p.lose(h_i)
        elsif dealer_value == player_value
          p.natural_21 ? p.win(h_i, 1.5) : p.push(h_i)
        else
          p.natural_21 ? p.win(h_i, 1.5) : p.win(h_i, 1)
        end
      end
    end # end of the hand
    p.clear
  end # end of players

  # END OF ROUND
  start_new_round ? next : break
end

puts 'Done' # END OF GAME