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
end
