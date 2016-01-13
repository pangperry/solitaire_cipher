require_relative 'keystreamgenerator'

class Solitaire
  LETTER_CONVERTER = Hash[('A'..'Z').zip (1..26)]
  NUMBER_CONVERTER = LETTER_CONVERTER.invert

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

  attr_reader(
    :message,
    :encrypted_message,
    :keystream_letters,
    :sanitized_message,
    :converted_message,
    :added_message_numbers,
    :cleaned_message,
    :grouped_message,
    :x_added,
    :converted_encrypted_message,
    :subtracted_message_numbers,
  )

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

  def convert_keystream_to_numbers
    @converted_keystream ||= convert_to_numbers(keystream).compact
  end

  def keystream
    keystream_length
    generator = KeystreamGenerator.new(keystream_length)
    @keystream_letters = generator.generate_keystream
  end

  def keystream_length
      if message.nil?
        length_no_spaces(encrypted_message)
      else
        length_no_spaces(sanitized_message)
      end
  end

  def length_no_spaces(str)
    str.gsub(/\s+/, '').length
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
