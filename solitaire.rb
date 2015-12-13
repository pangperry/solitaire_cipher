class Solitaire
  def initialize(opts={})
    @message           = opts[:message]
    @encrypted_message = opts[:encrypted_message]
    @keystream_letters = keystream
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
    a.zip(b).map { |x, y| x - y }
  end

  private

  LETTER_CONVERTER = Hash[('A'..'Z').zip (1..26)]
  NUMBER_CONVERTER = Hash[(1..26).zip ('A'..'Z')]

  attr_reader(
    :message,
    :encrypted_message,
    :keystream_letters,
    :sanitized_message,
    :converted_message,
    :converted_keystream,
    :added_message_numbers,
    :cleaned_message,
    :grouped_message,
    :x_added,
    :converted_encrypted_message,
    :subtracted_message_numbers
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
    @message.gsub(/\W+|\d+/, '').upcase
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
    convert_to_letters
  end

  def decrypt
    convert_encrypted_message
    #convert_keystream_to_numbers
    #subtract_message_numbers
    #convert_to_letters #refactor existing method
  end

  private

  LETTER_CONVERTER = Hash[('A'..'Z').zip (1..26)]
  NUMBER_CONVERTER = Hash[(1..26).zip ('A'..'Z')]

  attr_reader (
    :message,
    :encrypted_message,
    :keystream_letters,
    :sanitized_message,
    :converted_message,
    :converted_keystream,
    :added_message_numbers,
    :cleaned_message,
    :grouped_message,
    :x_added
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
    @message.gsub(/\W+|\d+/, '').upcase
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

  def keystream
    @keystream_letters = "DWJXH YRFDG TMSHP UURXJ"#must complete
  end

  def convert_message_to_numbers
    @converted_message = convert_to_numbers(sanitized_message).compact
  end

  def convert_to_numbers(letters)
    letters.chars.map { |letter| LETTER_CONVERTER[letter] }
  end

  def convert_keystream_to_numbers
    @converted_keystream = convert_to_numbers(keystream_letters).compact
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
    converted = numbers.map { |num| NUMBER_CONVERTER[num] }
    group(converted.join).join(" ")
  end

  #decrypt:

end
