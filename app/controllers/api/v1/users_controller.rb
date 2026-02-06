class Api::V1::UsersController < ApplicationController
  include Authentication
  skip_before_action :authenticate_request, only: [:index]
  before_action :authenticate_optional, only: [:index]

  # GET /api/v1/users
  def index
    users = User.all
    users = users.search_by_name(params[:query]) if params[:query].present?
    
    render json: users.map { |user| user_response(user) }, status: :ok
  end

  # GET /api/v1/users/me
  def me
    render json: user_response(current_user), status: :ok
  end

  # PUT /api/v1/users/me
  def update
    if current_user.update(user_update_params)
      render json: user_response(current_user), status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      picture: user.picture.attached? ? rails_blob_url(user.picture) : nil,
      created_at: user.created_at
    }
  end

  def user_update_params
    params.permit(:name, :email, :password, :password_confirmation, :picture)
  end
end

