require 'rails_helper'

RSpec.describe JsonWebToken do
  describe '.encode' do
    it 'encodes a payload with default expiration' do
      payload = { user_id: 1 }
      token = JsonWebToken.encode(payload)
      
      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it 'encodes a payload with custom expiration' do
      payload = { user_id: 1 }
      exp = 1.hour.from_now
      token = JsonWebToken.encode(payload, exp)
      
      decoded = JsonWebToken.decode(token)
      expect(decoded[:exp]).to be_within(1).of(exp.to_i)
    end
  end

  describe '.decode' do
    it 'decodes a valid token' do
      payload = { user_id: 1, email: 'test@example.com' }
      token = JsonWebToken.encode(payload)
      
      decoded = JsonWebToken.decode(token)
      expect(decoded[:user_id]).to eq(1)
      expect(decoded[:email]).to eq('test@example.com')
    end

    it 'returns nil for invalid token' do
      decoded = JsonWebToken.decode('invalid_token')
      expect(decoded).to be_nil
    end

    it 'returns nil for expired token' do
      payload = { user_id: 1 }
      token = JsonWebToken.encode(payload, 1.second.ago)
      
      sleep 1
      decoded = JsonWebToken.decode(token)
      expect(decoded).to be_nil
    end
  end
end
