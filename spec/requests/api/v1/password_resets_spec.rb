require 'rails_helper'

RSpec.describe "Api::V1::PasswordResets", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/password_resets" do
    context "with a valid email" do
      it "returns a success message" do
        post api_v1_password_resets_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Password reset instructions sent to your email')
      end

      it "generates a reset token" do
        expect {
          post api_v1_password_resets_path, params: { email: user.email }
        }.to change { user.reload.reset_password_token }.from(nil)
      end

      it "sends an email" do
        expect {
          post api_v1_password_resets_path, params: { email: user.email }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "with an invalid email" do
      it "returns the same success message to prevent user enumeration" do
        post api_v1_password_resets_path, params: { email: 'nonexistent@example.com' }
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Password reset instructions sent to your email')
      end
    end
  end

  describe "PUT /api/v1/password_resets/:id" do
    before { user.generate_password_reset_token! }

    context "with a valid token" do
      it "updates the password and clears the token" do
        put api_v1_password_reset_path(user.reset_password_token), params: {
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Password has been reset successfully')
        expect(user.reload.reset_password_token).to be_nil
        expect(user.authenticate('newpassword123')).to be_truthy
      end
    end

    context "with an invalid token" do
      it "returns not found" do
        put api_v1_password_reset_path('invalid_token'), params: {
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Invalid password reset token')
      end
    end

    context "with an expired token" do
      before do
        user.update_columns(reset_password_sent_at: 3.hours.ago)
      end

      it "returns gone" do
        put api_v1_password_reset_path(user.reset_password_token), params: {
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        expect(response).to have_http_status(:gone)
        expect(json_response['error']).to eq('Password reset token has expired')
      end
    end

    context "with invalid password params" do
      it "returns unprocessable entity" do
        put api_v1_password_reset_path(user.reset_password_token), params: {
          password: '123',
          password_confirmation: '123'
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end
end
