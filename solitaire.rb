class Solitaire
  def initialize(opts={})
    @message           = opts[:message]
    @encrypted_message = opts[:encrypted_message]
  end

  def encrypt
    sanitize_message
    convert_message_to_numbers
    convert_keystream_to_numbers
    add_message_numbers
    convert_to_letters(added_message_numbers)
  end

  def decrypt
    convert_encrypted_message_to_numbers
    convert_keystream_to_numbers
    subtract_message_numbers
    convert_to_letters(subtracted_message_numbers)
  end

  private

  LETTER_CONVERTER = Hash[('A'..'Z').zip (1..26)]
  NUMBER_CONVERTER = Hash[(1..26).zip ('A'..'Z')]

  attr_reader(
    :message,
    :encrypted_message,
    :keystream_length,
    :keystream_letters,
    :sanitized_message,
    :converted_message,
    :converted_keystream,
    :added_message_numbers,
    :cleaned_message,
    :grouped_message,
    :x_added,
    :converted_encrypted_message,
    :subtracted_message_numbers,
    :deck
  )

  #encrypt

  def sanitize_message
    clean_message
    group_message
    add_x(grouped_message)

    @sanitized_message = x_added.join(" ")
  end

  def clean_message
    @cleaned_message = discard_non_alpha_and_capitalize
  end

  def discard_non_alpha_and_capitalize
    message.gsub(/\W+|\d+/, '').upcase
  end

  def group_message
    @grouped_message = group(cleaned_message)
  end

  def group(str)
    str.scan(/.{1,5}/)
  end

  def add_x(ary)
    until ary.last.length == 5
      ary.last << 'X'
    end
    @x_added= ary
  end

#keystream------------------------

  def convert_keystream_to_numbers
    @converted_keystream = convert_to_numbers(keystream).compact
  end

  def keystream
   @keystream_letters ||= generate_keystream
  end

  def generate_keystream
    build_deck
    get_keystream_length
    generate_letters
  end

  def build_deck
    new_deck = (1..52).to_a
    new_deck << 'A'
    new_deck << 'B'
    @deck ||= new_deck
  end

  def get_keystream_length
    @keystream_length =
      if message.nil?
        length_no_spaces(encrypted_message)
      else
        length_no_spaces(sanitized_message)
      end
  end

  def length_no_spaces(str)
    str.gsub(/\s+/, '').length
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

  def convert_message_to_numbers
    @converted_message = convert_to_numbers(sanitized_message).compact
  end

  def convert_to_numbers(letters)
    letters.chars.map { |letter| LETTER_CONVERTER[letter] }
  end

  def add_message_numbers
    zipped = zip_add_messages(converted_message, converted_keystream)

    @added_message_numbers =
      zipped.map do |num|
        if num > 26
          num - 26
        else
          num
        end
      end
  end

  def zip_add_messages(a,b)
    a.zip(b).map { |x, y| x + y }
  end

  def convert_to_letters(numbers)
    converted = numbers.map do |num|
      num -= 26 if num > 26
      NUMBER_CONVERTER[num]
    end
    group(converted.join).join(" ")
  end

  #decrypt------------------------------

  def convert_encrypted_message_to_numbers
    @converted_encrypted_message =
      convert_to_numbers(encrypted_message).compact
  end

  def subtract_message_numbers
    zipped = zip_subtract_messages(converted_encrypted_message, converted_keystream)

    @subtracted_message_numbers =
      zipped.map do |num|
        if num <= 0
          num + 26
        else
          num
        end
      end
  end

  def zip_subtract_messages(a,b)
    a.zip(b).map { |x,y| x - y }
  end
end
