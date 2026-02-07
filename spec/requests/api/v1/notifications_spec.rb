require 'rails_helper'

RSpec.describe "Api::V1::Notifications", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /api/v1/notifications" do
    before do
      create(:notification, user: user, title: "N1")
      create(:notification, user: other_user, title: "N2")
    end

    it "returns notifications for the current user" do
      get "/api/v1/notifications", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json[0]['title']).to eq("N1")
    end
  end

  describe "Triggers" do
    let(:proposer) { user }
    let(:receiver) { other_user }
    let(:p_item) { create(:item, user: proposer) }
    let(:r_item) { create(:item, user: receiver) }

    it "creates a notification when a trade is created" do
      expect {
        create(:trade, proposer: proposer, receiver: receiver, proposer_item: p_item, receiver_item: r_item)
      }.to change(Notification, :count).by(1)
      
      notification = Notification.last
      expect(notification.user).to eq(receiver)
      expect(notification.notification_type).to eq("trade_requested")
    end

    it "creates a notification when a message is sent" do
      trade = create(:trade, proposer: proposer, receiver: receiver, proposer_item: p_item, receiver_item: r_item, status: 'accepted')
      
      expect {
        create(:message, trade: trade, user: proposer, content: "Hi")
      }.to change(Notification, :count).by(1)
      
      notification = Notification.last
      expect(notification.user).to eq(receiver)
      expect(notification.notification_type).to eq("new_message")
    end
  end
end
