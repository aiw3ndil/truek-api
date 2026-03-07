require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let!(:user1) { create(:user, name: "John Doe") }
  let!(:user2) { create(:user, name: "Jane Smith") }
  let!(:user3) { create(:user, name: "Johnny Bravo") }

  describe "GET /api/v1/users" do
    it "returns all users" do
      get "/api/v1/users"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
    end

    it "filters users by name (case-insensitive)" do
      get "/api/v1/users", params: { query: "john" }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2) # John Doe, Johnny Bravo
      expect(json_response.map { |u| u['name'] }).to include("John Doe", "Johnny Bravo")
    end

    it "returns empty array when no users match" do
      get "/api/v1/users", params: { query: "NonExistent" }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(0)
    end
  end

  describe "Authenticated user actions" do
    let(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    describe "GET /api/v1/users/me" do
      it "returns the current user" do
        get "/api/v1/users/me", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['email']).to eq(user.email)
      end
    end

    describe "PUT /api/v1/users/me" do
      it "updates the current user" do
        put "/api/v1/users/me", params: { name: "New Name" }, headers: headers
        expect(response).to have_http_status(:ok)
        expect(user.reload.name).to eq("New Name")
      end
    end

    describe "POST /api/v1/users/me/change_password" do
      it "changes password with correct current password" do
        post "/api/v1/users/me/change_password", 
             params: { current_password: 'password123', password: 'newpassword123', password_confirmation: 'newpassword123' }, 
             headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(user.reload.authenticate('newpassword123')).to be_truthy
      end

      it "fails with incorrect current password" do
        post "/api/v1/users/me/change_password", 
             params: { current_password: 'wrong_password', password: 'newpassword123', password_confirmation: 'newpassword123' }, 
             headers: headers
        
        expect(response).to have_http_status(:unauthorized)
        expect(user.reload.authenticate('newpassword123')).to be_falsey
      end

      it "fails with invalid password confirmation" do
        post "/api/v1/users/me/change_password", 
             params: { current_password: 'password123', password: 'newpassword123', password_confirmation: 'mismatch' }, 
             headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
