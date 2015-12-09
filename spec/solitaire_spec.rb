require 'spec_helper'
require_relative '../solitaire-v1'

describe Solitaire, '#encrypt_message' do
  it 'successfully encrypts a message' do
    message = 'Code in Ruby, live longer!'
    expected_output = 'GLNCQ MJAFF FVOMB JIYCB'

    encrypted_message = Solitaire.new(message).encrypt_message

    expect(encrypted_message).to eq expected_output
  end
end

describe Solitaire, '#decrypt_message' do
  it 'successfully decrypts a message' do
    encrypted_message = 'CLEPK HHNIY CFPWH FDFEH'
    expected_output = 'YOURC IPHER ISWOR KINGX'

    decrypted_message = Solitaire.new(encrypted_message).decrypt_message

    expect(decrypted_message).to eq expected_output
  end
end
