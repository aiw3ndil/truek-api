require 'rails_helper'

RSpec.describe "Api::V1::Trades", type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:item1) { create(:item, user: user1) }
  let(:item2) { create(:item, user: user2) }
  let(:token1) { JsonWebToken.encode(user_id: user1.id) }
  let(:token2) { JsonWebToken.encode(user_id: user2.id) }
  let(:headers1) { { 'Authorization' => "Bearer #{token1}" } }
  let(:headers2) { { 'Authorization' => "Bearer #{token2}" } }

  describe "GET /api/v1/trades" do
    let!(:trade1) { create(:trade, proposer: user1, receiver: user2, proposer_item: item1, receiver_item: item2) }
    let!(:trade2) { create(:trade, proposer: user2, receiver: user1, proposer_item: create(:item, user: user2), receiver_item: create(:item, user: user1)) }

    it "returns trades for current user" do
      get "/api/v1/trades", headers: headers1
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
    end

    it "filters trades by status" do
      trade1.update(status: 'accepted')
      get "/api/v1/trades", params: { status: 'accepted' }, headers: headers1
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['status']).to eq('accepted')
    end

    it "returns unauthorized without token" do
      get "/api/v1/trades"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/trades/:id" do
    let(:trade) { create(:trade, proposer: user1, receiver: user2, proposer_item: item1, receiver_item: item2) }

    it "returns trade details for proposer" do
      get "/api/v1/trades/#{trade.id}", headers: headers1
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(trade.id)
      expect(json_response['proposer']['id']).to eq(user1.id)
    end

    it "returns trade details for receiver" do
      get "/api/v1/trades/#{trade.id}", headers: headers2
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(trade.id)
    end

    it "returns forbidden for non-participant" do
      user3 = create(:user)
      token3 = JsonWebToken.encode(user_id: user3.id)
      headers3 = { 'Authorization' => "Bearer #{token3}" }
      get "/api/v1/trades/#{trade.id}", headers: headers3
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/trades" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          trade: {
            receiver_id: user2.id,
            proposer_item_id: item1.id,
            receiver_item_id: item2.id
          }
        }
      end

      it "creates a new trade" do
        expect {
          post "/api/v1/trades", params: valid_params, headers: headers1
        }.to change(Trade, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('pending')
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          trade: {
            receiver_id: user1.id,
            proposer_item_id: item1.id,
            receiver_item_id: item2.id
          }
        }
      end

      it "returns unprocessable entity when trading with self" do
        post "/api/v1/trades", params: invalid_params, headers: headers1
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns unauthorized without token" do
      post "/api/v1/trades", params: { trade: {} }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /api/v1/trades/:id" do
    let(:trade) { create(:trade, proposer: user1, receiver: user2, proposer_item: item1, receiver_item: item2) }

    context "accept action" do
      it "allows receiver to accept trade" do
        put "/api/v1/trades/#{trade.id}", 
            params: { action_type: 'accept' }, 
            headers: headers2
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('accepted')
      end

      it "prevents proposer from accepting trade" do
        put "/api/v1/trades/#{trade.id}", 
            params: { action_type: 'accept' }, 
            headers: headers1
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "reject action" do
      it "allows receiver to reject trade" do
        put "/api/v1/trades/#{trade.id}", 
            params: { action_type: 'reject' }, 
            headers: headers2
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('rejected')
      end
    end

    context "cancel action" do
      it "allows proposer to cancel trade" do
        put "/api/v1/trades/#{trade.id}", 
            params: { action_type: 'cancel' }, 
            headers: headers1
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('cancelled')
      end

      it "prevents receiver from cancelling trade" do
        put "/api/v1/trades/#{trade.id}", 
            params: { action_type: 'cancel' }, 
            headers: headers2
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "complete action" do
      it "completes accepted trade and updates items" do
        trade.update(status: 'accepted')
        put "/api/v1/trades/#{trade.id}", 
            params: { action_type: 'complete' }, 
            headers: headers1
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('completed')
        expect(item1.reload.status).to eq('traded')
        expect(item2.reload.status).to eq('traded')
      end
    end
  end
end
