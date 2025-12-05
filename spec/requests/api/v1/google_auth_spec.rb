require 'rails_helper'

RSpec.describe "Api::V1::GoogleAuth", type: :request do
  let(:valid_google_data) do
    {
      sub: 'google-user-123',
      email: 'user@gmail.com',
      name: 'Google User',
      picture: 'https://example.com/photo.jpg',
      email_verified: true
    }
  end

  describe "POST /api/v1/auth/google" do
    context 'with valid Google token' do
      before do
        allow(GoogleAuthService).to receive(:verify_token).and_return(valid_google_data)
      end

      it 'creates a new user from Google data' do
        expect {
          post '/api/v1/auth/google', params: { token: 'valid_google_token' }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
        expect(json_response).to have_key('user')
        expect(json_response['user']['email']).to eq('user@gmail.com')
        expect(json_response['user']['provider']).to eq('google')
      end

      it 'returns existing user if already registered' do
        create(:user, :google_user, email: 'user@gmail.com', google_id: 'google-user-123')

        expect {
          post '/api/v1/auth/google', params: { token: 'valid_google_token' }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
      end

      it 'links Google account to existing email user' do
        user = create(:user, email: 'user@gmail.com', provider: 'email')

        post '/api/v1/auth/google', params: { token: 'valid_google_token' }

        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.google_id).to eq('google-user-123')
        expect(user.provider).to eq('google')
      end

      it 'includes user picture in response' do
        post '/api/v1/auth/google', params: { token: 'valid_google_token' }

        expect(response).to have_http_status(:ok)
        expect(json_response['user']['picture']).to eq('https://example.com/photo.jpg')
      end
    end

    context 'with invalid Google token' do
      before do
        allow(GoogleAuthService).to receive(:verify_token).and_return(nil)
      end

      it 'returns unauthorized error' do
        post '/api/v1/auth/google', params: { token: 'invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid Google token')
      end
    end

    context 'without token' do
      it 'returns bad request error' do
        post '/api/v1/auth/google'

        expect(response).to have_http_status(:bad_request)
        expect(json_response['error']).to eq('Token is required')
      end
    end

    context 'with unverified email' do
      before do
        unverified_data = valid_google_data.merge(email_verified: false)
        allow(GoogleAuthService).to receive(:verify_token).and_return(unverified_data)
      end

      it 'returns unauthorized error' do
        post '/api/v1/auth/google', params: { token: 'token_with_unverified_email' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Email not verified')
      end
    end
  end
end
