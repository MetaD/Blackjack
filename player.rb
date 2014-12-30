require_relative 'hand'

INITIAL_MONEY = 1000

# Represents a player who holds and plays cards
class Player
  def initialize(name)
    self.name = name
    self.money = INITIAL_MONEY
    self.hands = [Hand.new] # has one hand at the beginning
    self.round_ended = false
    self.natural_21 = false
  end

  # bet the specified amount on the specified hand
  def bet(hand_num, amount)
    raise 'Invalid bet' if amount > self.money || hand_num < 0 || hand_num >= hands.size
    self.money -= amount
    hands[hand_num].add_bet(amount)
  end

  # add one card to the specified hand and check the result
  # card information is printed to output if announce == true
  def add_card(card, hand_num = 0, announce)
    hands[hand_num] << card
    self.natural_21 = true if (hands[hand_num].cards.size == 2 &&
        hands[hand_num].has_21 && !hands[hand_num].splitted)
    puts get_official_name + " dealt #{card}" if announce

    if hands[hand_num].has_21 && announce
      print get_official_name + ' has '
      puts (natural_21 ? 'a blackjack!' : '21!')
      self.round_ended = true
    elsif hands[hand_num].value > 21 # busted
      puts get_official_name + " busted with #{hands[hand_num].value}!"
    end
    card
  end

  # add the new hand to the end of hands
  def add_hand(hand)
    raise 'invalid split' if money < hand.bet
    hands << hand
    self.money -= hand.bet
  end

  # discards all the cards of the player and resets to the initial state
  def clear
    self.hands = [Hand.new]
    self.round_ended = false
    self.natural_21 = false
  end

  # a helper function for win/push/lose to print the result to output
  def print_result(result, hand_num, gain = 0)
    puts "Player #{name} #{result}" +
             (gain == 0 ? '' : " $#{gain}") + # print the gain if there is any
             (hands.size == 1 ? '' : " for hand ##{hand_num+1}")
             # print hand_num if player has multiple hands
  end

  # player wins the hand with hand_num
  def win(hand_num, pay_ratio)
    gain = hands[hand_num].bet * pay_ratio
    self.money += gain + hands[hand_num].bet
    print_result('won', hand_num, gain)
  end

  def push(hand_num)
    self.money += hands[hand_num].bet
    print_result('pushed', hand_num)
  end

  def lose(hand_num)
    print_result('lost', hand_num)
  end

  # return either 'Dealer' or 'Player <name>'
  def get_official_name
     name == 'Dealer' ? 'Dealer' : "Player #{name}"
  end

  # print the information of the player
  def print_info
    puts get_official_name
    # Dealer
    if name == 'Dealer' # Dealer wouldn't have money or multiple hands
      puts "   Cards: #{hands[0]}"
      return
    end
    # Player
    puts "   Money: #{money}"
    print '   Cards: '
    if hands.size == 1
      puts "      #{hands[0]}"
    else
      puts '' # a new line
      hands.each_with_index { |hand, i| puts "      Hand #{i+1}: #{hand}" }
    end
  end

  attr_reader :name, :money, :hands, :round_ended, :natural_21
  protected
  attr_writer :name, :money, :hands, :round_ended, :natural_21
end