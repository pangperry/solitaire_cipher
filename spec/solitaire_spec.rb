require 'spec_helper'
require_relative '../solitaire'

describe Solitaire,"#encrypt" do
  it 'successfully encrypts message with unkeyed deck' do
    message = 'Code in Ruby, live longer!'
    expected_output = 'GLNCQ MJAFF FVOMB JIYCB'

    encrypted_message = Solitaire.new(message: message).encrypt

    expect(encrypted_message).to eq expected_output
  end
end

describe Solitaire, "#decrypt" do
  it 'successfully decrypts message' do
    encrypted_message = 'GLNCQ MJAFF FVOMB JIYCB'
    expected_output = "CODEI NRUBY LIVEL ONGER"

    decrypted_message = Solitaire.new(encrypted_message: encrypted_message).decrypt

    expect(decrypted_message).to eq expected_output
  end
end
