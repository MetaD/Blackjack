require_relative 'card'

# Represents a hand of cards
class Hand
  def initialize(splitted = false)
    self.cards = []
    self.value = 0
    self.soft = false
    self.bet = 0
    self.splitted = splitted
  end

  # add a card to cards
  def <<(card)
    cards << card
    self.value += card.value
    self.soft = true if card.rank == 'A'
  end

  def add_bet(amount)
    self.bet += amount
  end

  # return true if the value of this hand is 21, false otherwise
  def has_21
    value == 21 || (value == 11 && soft)
  end

  # return true if this hand can be splitted, false otherwise
  def can_split
    cards.size == 2 && cards[0].value == cards[1].value
  end

  # return one of the cards and remove it from the current hand
  # when calling this function, the caller is responsible to first check whether splittable
  def split
    raise 'Cannot split!' unless can_split  # produce a runtime error
    # create a new hand with the splitted card and return it
    new_hand = Hand.new(true)
    new_hand << cards[1]
    new_hand.bet = bet
    self.splitted = true
    self.value -= cards[1].value
    cards.delete_at(1)
    new_hand
  end

  # used for output
  def to_s
    if cards.empty?
      'None'
    else
      cards.join(', ') + (soft && value < 12 ? "  (#{value}/#{value+10})" : "  (#{value})")
    end
  end

  attr_reader :cards, :value, :soft, :bet, :splitted
  protected
  attr_writer :cards, :value, :soft, :bet, :splitted
  # splitted == true indicates this hand is a result of splitting
end