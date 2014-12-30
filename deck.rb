require_relative 'card'

# Represents a deck of 52 cards
class Deck
  def initialize
    # shuffle array and initialize each Card
    self.cards = (0..51).to_a.shuffle.collect { |card_id| Card.new(card_id) }
    self.next_card = 0
  end

  # return the next card on the deck
  def deal
    # replace with a new deck when the current is empty
    initialize if next_card > 51
    self.next_card += 1
    cards[self.next_card - 1]
  end

  protected
  attr_accessor :cards, :next_card
end