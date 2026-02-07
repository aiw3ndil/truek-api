require 'rails_helper'

RSpec.describe "Api::V1::Messages", type: :request do
  let(:proposer) { create(:user) }
  let(:receiver) { create(:user) }
  let(:third_party) { create(:user) }
  let(:trade) { create(:trade, proposer: proposer, receiver: receiver, status: 'pending') }
  
  let(:proposer_token) { JsonWebToken.encode(user_id: proposer.id) }
  let(:receiver_token) { JsonWebToken.encode(user_id: receiver.id) }
  let(:third_party_token) { JsonWebToken.encode(user_id: third_party.id) }
  
  let(:proposer_headers) { { 'Authorization' => "Bearer #{proposer_token}" } }
  let(:receiver_headers) { { 'Authorization' => "Bearer #{receiver_token}" } }
  let(:third_party_headers) { { 'Authorization' => "Bearer #{third_party_token}" } }

  describe "GET /api/v1/trades/:trade_id/messages" do
    it "proposer can see messages even if pending (e.g. empty list)" do
      get "/api/v1/trades/#{trade.id}/messages", headers: proposer_headers
      expect(response).to have_http_status(:ok)
    end

    context "when trade is accepted" do
      before { trade.update(status: 'accepted') }

      it "returns messages for participants" do
        get "/api/v1/trades/#{trade.id}/messages", headers: proposer_headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.length).to be >= 1 # System message
      end

      it "denies access to non-participants" do
        get "/api/v1/trades/#{trade.id}/messages", headers: third_party_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/trades/:trade_id/messages" do
    let(:valid_params) { { message: { content: "Hello!" } } }

    context "when trade is pending" do
      it "returns forbidden" do
        post "/api/v1/trades/#{trade.id}/messages", params: valid_params, headers: proposer_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when trade is accepted" do
      before { trade.update(status: 'accepted') }

      it "allows participants to send messages" do
        expect {
          post "/api/v1/trades/#{trade.id}/messages", params: valid_params, headers: proposer_headers
        }.to change(Message, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "creates a notification for the recipient when sent via API" do
        post "/api/v1/trades/#{trade.id}/messages", params: valid_params, headers: proposer_headers
        expect(response).to have_http_status(:created)
        
        get "/api/v1/notifications", headers: receiver_headers
        json = JSON.parse(response.body)
        expect(json.any? { |n| n['notification_type'] == 'new_message' }).to be true
      end
    end
  end
end
