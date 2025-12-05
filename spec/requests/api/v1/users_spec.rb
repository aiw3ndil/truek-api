require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/users/me" do
    context 'when authenticated' do
      it 'returns current user data' do
        get '/api/v1/users/me', headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['email']).to eq(user.email)
        expect(json_response['name']).to eq(user.name)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/users/me'
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized error' do
        get '/api/v1/users/me', headers: { 'Authorization' => 'Bearer invalid_token' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end

  describe "PUT /api/v1/users/me" do
    context 'when authenticated' do
      it 'updates user name' do
        put '/api/v1/users/me', params: { name: 'New Name' }, headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response['name']).to eq('New Name')
        expect(user.reload.name).to eq('New Name')
      end

      it 'updates user email' do
        put '/api/v1/users/me', params: { email: 'newemail@example.com' }, headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response['email']).to eq('newemail@example.com')
        expect(user.reload.email).to eq('newemail@example.com')
      end

      it 'updates user password' do
        put '/api/v1/users/me', params: { password: 'newpassword123', password_confirmation: 'newpassword123' }, headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(user.reload.authenticate('newpassword123')).to be_truthy
      end

      it 'returns error with invalid email' do
        put '/api/v1/users/me', params: { email: 'invalid_email' }, headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(match(/email/i))
      end

      it 'returns error when email is already taken' do
        other_user = create(:user, email: 'taken@example.com')
        put '/api/v1/users/me', params: { email: 'taken@example.com' }, headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(match(/email/i))
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized error' do
        put '/api/v1/users/me', params: { name: 'New Name' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end
end
