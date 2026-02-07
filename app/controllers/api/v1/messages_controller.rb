class Api::V1::MessagesController < ApplicationController
  include Authentication
  before_action :set_trade
  before_action :authorize_trade_participant
  before_action :ensure_accepted_trade, only: [:create]

  # GET /api/v1/trades/:trade_id/messages
  def index
    messages = @trade.messages.includes(:user).order(created_at: :asc)
    render json: messages.map { |msg| message_response(msg) }, status: :ok
  end

  # POST /api/v1/trades/:trade_id/messages
  def create
    message = @trade.messages.new(message_params)
    message.user = current_user

    if message.save
      render json: message_response(message), status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_trade
    @trade = Trade.find(params[:trade_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trade not found' }, status: :not_found
  end

  def authorize_trade_participant
    unless @trade.proposer_id == current_user.id || @trade.receiver_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end

  def ensure_accepted_trade
    unless @trade.status == 'accepted' || @trade.status == 'completed'
      render json: { error: 'Comunication channel is only open for accepted or completed trades' }, status: :forbidden
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def message_response(message)
    {
      id: message.id,
      content: message.content,
      sender: {
        id: message.user.id,
        name: message.user.name,
        picture: message.user.picture.attached? ? rails_blob_url(message.user.picture) : nil
      },
      created_at: message.created_at
    }
  end
end
