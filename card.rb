# Represents one card
class Card
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  SUITS = %w(Spade Heart Club Diamond)

  def initialize(id)  # each card can be represented with a unique ID
    self.rank = RANKS[id % 13]
    self.suit = SUITS[id % 4]
    # Rank 2 - 9 counts as 2 - 9, rank J - K counts as 10
    self.value = (id % 13 < 9) ? rank.to_i : 10
    # Ace counts as 1 for now
    self.value = 1 if id % 13 == 12
  end

  # used for output
  def to_s
    "#{rank} #{suit}"
  end

  attr_reader :rank, :suit, :value
  protected
  attr_writer :rank, :suit, :value
end