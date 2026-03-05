class Api::V1::PasswordResetsController < ApplicationController
  # POST /api/v1/password_resets
  def create
    user = User.find_by(email: params[:email]&.downcase)
    
    if user
      user.generate_password_reset_token!
      UserMailer.password_reset_email(user.reload).deliver_now
      render json: { message: 'Password reset instructions sent to your email' }, status: :ok
    else
      # We return :ok even if user is not found to prevent user enumeration
      render json: { message: 'Password reset instructions sent to your email' }, status: :ok
    end
  end

  # PUT/PATCH /api/v1/password_resets/:token
  def update
    user = User.find_by(reset_password_token: params[:id])
    
    if user && !user.password_reset_expired?
      if user.update(password_params)
        user.clear_password_reset_token!
        render json: { message: 'Password has been reset successfully' }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    elsif user&.password_reset_expired?
      render json: { error: 'Password reset token has expired' }, status: :gone
    else
      render json: { error: 'Invalid password reset token' }, status: :not_found
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end
end
