require 'rails_helper'

RSpec.describe "Api::V1::Authentication", type: :request do
  describe "POST /api/v1/auth/signup" do
    let(:valid_params) do
      {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user and returns a token' do
        expect {
          post '/api/v1/auth/signup', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response).to have_key('token')
        expect(json_response).to have_key('user')
        expect(json_response['user']['email']).to eq('john@example.com')
        expect(json_response['user']['name']).to eq('John Doe')
      end

      it 'downcases email' do
        post '/api/v1/auth/signup', params: valid_params.merge(email: 'JOHN@EXAMPLE.COM')
        
        expect(response).to have_http_status(:created)
        expect(User.last.email).to eq('john@example.com')
      end
    end

    context 'with invalid parameters' do
      it 'returns error when email is missing' do
        post '/api/v1/auth/signup', params: valid_params.except(:email)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end

      it 'returns error when password is too short' do
        post '/api/v1/auth/signup', params: valid_params.merge(password: '12345', password_confirmation: '12345')
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(match(/password/i))
      end

      it 'returns error when email is already taken' do
        create(:user, email: 'john@example.com')
        post '/api/v1/auth/signup', params: valid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(match(/email/i))
      end

      it 'returns error when password confirmation does not match' do
        post '/api/v1/auth/signup', params: valid_params.merge(password_confirmation: 'different')
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(match(/password/i))
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: 'john@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token and user data' do
        post '/api/v1/auth/login', params: { email: 'john@example.com', password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
        expect(json_response).to have_key('user')
        expect(json_response['user']['email']).to eq('john@example.com')
      end

      it 'works with uppercase email' do
        post '/api/v1/auth/login', params: { email: 'JOHN@EXAMPLE.COM', password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns error with wrong password' do
        post '/api/v1/auth/login', params: { email: 'john@example.com', password: 'wrong_password' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns error with non-existent email' do
        post '/api/v1/auth/login', params: { email: 'nonexistent@example.com', password: 'password123' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end
end
