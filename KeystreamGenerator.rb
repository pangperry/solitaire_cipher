class KeystreamGenerator

  attr_reader :keystream_length

  def initialize(keystream_length)
    @keystream_length = keystream_length
  end

  def generate_keystream
    deck
    generate_letters
  end

  private

  NUMBER_CONVERTER = Hash[(1..26).zip ('A'..'Z')]

  def deck
    @deck ||= build_deck
  end

  def build_deck
    new_deck = (1..52).to_a
    new_deck << 'A'
    new_deck << 'B'
    new_deck
  end


  def generate_letters
    new_keystream = []
    letters_added = 0

    until letters_added == keystream_length do
      new_keystream << cut_deck_and_output_letter
      new_keystream.last == nil ? letters_added : letters_added += 1
    end

    new_keystream.compact.join
  end

  def cut_deck_and_output_letter
    move_joker_a
    move_joker_b
    triple_cut
    count_cut
    output_letter
  end

  def move_joker_a
    old_position = deck.index('A')

    if old_position == 53
      new_position = 1
    else
      new_position = old_position + 1
    end

    @deck = deck.insert(new_position, deck.delete_at(old_position))
  end

  def move_joker_b
    old_position = deck.index('B')

    if old_position == 53
      new_position = 2
    elsif
      old_position == 52
      new_position = 1
    else
      new_position = old_position + 2
    end

    @deck = deck.insert(new_position, deck.delete_at(old_position))
  end

  def triple_cut
    joker_a_position = deck.index('A')
    joker_b_position = deck.index('B')

    move_to_top = []
    move_to_bottom = []

    if joker_a_position > joker_b_position
      (53-joker_a_position).times do
        move_to_top << deck.pop
      end
      move_to_top.reverse!

      joker_b_position.times do
        move_to_bottom << deck.shift
        move_to_bottom
      end
    else
      (53-joker_b_position).times do
        move_to_top << deck.pop
      end
      move_to_top.reverse!

      joker_a_position.times do
        move_to_bottom << deck.shift
        move_to_bottom
      end
    end

    @deck = (move_to_top.concat(deck)).concat(move_to_bottom)
  end

  def count_cut
    cards_to_insert = []

    card_value =
      if deck.last.is_a?(String)
        53
      else
        deck.last
      end

    card_value.times do
      cards_to_insert << deck.shift
    end
    @deck = deck.insert(-2,cards_to_insert).flatten
  end

  def output_letter
    top_card =
      if deck.first.is_a?(String)
        53
      else
        deck.first
      end

    card_to_convert = deck[top_card]

    if card_to_convert.is_a?(String)
      nil
    else
      card_to_convert -= 26 if card_to_convert > 26
      NUMBER_CONVERTER[card_to_convert]
    end
  end
end
