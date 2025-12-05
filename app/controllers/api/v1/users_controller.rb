class Api::V1::UsersController < ApplicationController
  include Authentication

  # GET /api/v1/users/me
  def me
    render json: {
      id: current_user.id,
      name: current_user.name,
      email: current_user.email,
      created_at: current_user.created_at
    }, status: :ok
  end

  # PUT /api/v1/users/me
  def update
    if current_user.update(user_update_params)
      render json: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        updated_at: current_user.updated_at
      }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_update_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end

