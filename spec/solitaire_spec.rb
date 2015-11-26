require 'spec_helper'
require_relative '../solitaire'

describe Solitaire, '#decrypt_message' do
  it 'successfully decrypts a message' do
    encrypted_message = 'CLEPK HHNIY CFPWH FDFEH'
    expected_output = 'YOURC IPHER ISWOR KINGX'

    decrypted_message = Solitaire.new.decrypt_message(encrypted_message)

    expect(decrypted_message).to eq expected_output
  end
end

describe Solitaire, '#encrypt_message' do
  it 'successfully encrypts a message' do
    message = 'Your cipher is working'
    expected_output = 'CLEPK HHNIY CFPWH FDFEH'

    encrypted_message  = Solitaire.new.encrypt_message(message)

    expect(encrypted_message).to eq expected_output
  end
end
