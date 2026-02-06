require 'rails_helper'

RSpec.describe "Api::V1::Items", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /api/v1/items" do
    let!(:items) { create_list(:item, 3, user: user) }
    let!(:other_items) { create_list(:item, 2, user: other_user) }

    it "returns all available items" do
      get "/api/v1/items"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(5)
    end

    it "filters items by user_id" do
      get "/api/v1/items", params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
    end

    it "filters items by title query" do
      create(:item, title: "Special Item", user: user)
      get "/api/v1/items", params: { query: "special" }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['title']).to eq("Special Item")
    end
  end

  describe "GET /api/v1/items/:id" do
    let(:item) { create(:item, :with_images, user: user) }

    it "returns item details" do
      get "/api/v1/items/#{item.id}"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(item.id)
      expect(json_response['title']).to eq(item.title)
      expect(json_response['images'].length).to eq(3)
    end

    it "returns 404 for non-existent item" do
      get "/api/v1/items/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/items" do
    context "with valid parameters" do
      let(:image) { fixture_file_upload(Rails.root.join('spec/fixtures/files/image.jpg'), 'image/jpeg') }
      let(:valid_params) do
        {
          item: {
            title: "Test Item",
            description: "Test Description",
            item_images_attributes: [
              { file: image, position: 0 }
            ]
          }
        }
      end

      it "creates a new item" do
        expect {
          post "/api/v1/items", params: valid_params, headers: headers
        }.to change(Item, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq("Test Item")
        expect(json_response['images'].length).to eq(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { item: { title: "Te", description: "Test" } } }

      it "returns unprocessable entity" do
        post "/api/v1/items", params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/api/v1/items", params: { item: { title: "Test" } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/items/:id" do
    let(:item) { create(:item, user: user) }

    context "as item owner" do
      it "updates the item" do
        put "/api/v1/items/#{item.id}", 
            params: { item: { title: "Updated Title" } }, 
            headers: headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq("Updated Title")
      end
    end

    context "as different user" do
      let(:other_token) { JsonWebToken.encode(user_id: other_user.id) }
      let(:other_headers) { { 'Authorization' => "Bearer #{other_token}" } }

      it "returns forbidden" do
        put "/api/v1/items/#{item.id}", 
            params: { item: { title: "Hacked" } }, 
            headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/items/:id" do
    let!(:item) { create(:item, user: user) }

    context "as item owner" do
      it "deletes the item" do
        expect {
          delete "/api/v1/items/#{item.id}", headers: headers
        }.to change(Item, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "as different user" do
      let(:other_token) { JsonWebToken.encode(user_id: other_user.id) }
      let(:other_headers) { { 'Authorization' => "Bearer #{other_token}" } }

      it "returns forbidden" do
        delete "/api/v1/items/#{item.id}", headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
