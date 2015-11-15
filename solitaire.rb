class Solitaire
  attr_reader :deck

  def initialize
    @deck = build_deck.shuffle!
  end

  def encrypt_message(message)
    key = @deck.dup
    cleaned_message =  prepare(message)
    converted_message = convert_message(cleaned_message)
    keystream_message = generate_keystream_message(cleaned_message,key)
    converted_keystream = convert_message(keystream_message)
    added_messages = add_message_numbers(converted_message, converted_keystream) #this is the difference between encrypt and decrypt
    convert_characters(added_messages).map(&:join).join(' ')
  end

  def decrypt_message(message)
    key = @deck.dup
    cleaned_message =  prepare(message)
    converted_message = convert_message(cleaned_message)
    keystream_message = generate_keystream_message(cleaned_message,key)
    converted_keystream = convert_message(keystream_message)
    messages_subtracted = subtract_message_numbers(converted_message, converted_keystream) #this is the difference between encrypt and decrypt
    convert_characters(messages_subtracted).map(&:join).join(' ')
  end

  def subtract_message_numbers(message_numbers, keystream_numbers)
    subtracted = keystream_numbers.flatten.zip(message_numbers.flatten).map do |x, y|
      y <= x ? (y + 26) - x : y - x
    end
    subtracted.each_slice(5).to_a
  end

  def convert_message(grouped_message)
    convert_characters(grouped_message)
  end

  def add_message_numbers(message_numbers, keystream_numbers)
    added = [message_numbers.flatten, keystream_numbers.flatten].transpose.map {|x| x.reduce(:+) }
    (added.map {|num| num>26 ? num - 26: num }).each_slice(5).to_a
  end

  def convert_characters(grouped_message)
    grouped_message.map {|group| group.map { |character| converter(character) } }
  end

  def converter(character)
    converter = Hash[(("A".."Z").to_a).zip(1..26)]#not very efficient to do this over everytime
    character.is_a?(Integer) ? converter.invert[character]: converter[character]
  end

  def prepare(message)
    grouped_caps = substitute_chars(message).chars.each_slice(5).to_a
    add_x(grouped_caps)
  end

  def substitute_chars(message)
    message.gsub(/\p{^Alnum}/, '').upcase
  end

  def add_x(grouped_message)
    grouped_message.last << "X" until grouped_message.last.count % 5 == 0
    grouped_message
  end

  def generate_keystream_message(prepared_message,deck)
    keystream_message = prepared_message.map {|group| group.map {|letter| gen_keystream_letter(letter, deck) }}
  end

  def gen_keystream_letter(letter, deck)
    number = move_jokers_and_cut_deck(deck)
    number > 26 ? number = number -26 : number#this breaks here, because it will work recursive until it hits a joker
    converter(number)
  end

  def move_jokers_and_cut_deck(deck)
    move_joker_a(deck)
    move_joker_b(deck)
    triple_cut(deck)
    count_cut(deck)
    card_value(deck.first) == "joker" ? move_jokers_and_cut_deck(deck) : deck.first
  end

  def card_value(card)
    card.is_a?(String) ? "joker" : card
  end

  def build_deck
    cards = (1..52).to_a
    cards << "A"
    cards << "B"
  end

  def count_cut(deck)
    bottom_card = deck.pop
    bottom_card.is_a?(String) ? value = 53 : value = bottom_card
    value.times { deck << deck.shift }
    deck << bottom_card
  end

  def triple_cut(deck)
    position_a = deck.index('A')
    position_b = deck.index('B')
    if position_b > position_a
      top = deck[position_b+1..53]
      bottom = deck[0..position_a-1]
      middle = deck[position_a..position_b]
      top.concat(middle).concat(bottom)
    else
      top = deck[position_a+1..53]
      bottom = deck[0..position_b-1]
      middle = deck[position_b..position_a]
      top.concat(middle).concat(bottom)
    end
  end

  def move_joker_a(deck)
    position = deck.index('A')
    position == 53 ? deck.insert(1,deck.delete_at(53)) : deck.insert((position+1),deck.delete_at(position))
  end

  def move_joker_b(deck)
    position = deck.index('B')
    if position == 53
      deck.insert(2,deck.delete_at(53))
    elsif position == 52
      deck.insert(1,deck.delete_at(52))
    else
      deck.insert((position+2),deck.delete_at(position))
    end
  end

  def shuffle(deck)
    @deck.shuffle!
  end
end
