class Api::V1::GoogleAuthController < ApplicationController
  # POST /api/v1/auth/google
  def authenticate
    google_token = params[:token]
    
    unless google_token
      render json: { error: 'Token is required' }, status: :bad_request
      return
    end

    google_data = GoogleAuthService.verify_token(google_token)
    
    unless google_data
      render json: { error: 'Invalid Google token' }, status: :unauthorized
      return
    end

    unless google_data[:email_verified]
      render json: { error: 'Email not verified' }, status: :unauthorized
      return
    end

    user = User.from_google(google_data)
    
    if user.persisted?
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        token: token,
        user: user_response(user)
      }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      picture: user.picture,
      provider: user.provider,
      created_at: user.created_at
    }
  end
end
