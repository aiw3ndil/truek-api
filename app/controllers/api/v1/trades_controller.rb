class Api::V1::TradesController < ApplicationController
  include Authentication
  before_action :set_trade, only: [:show, :update]
  before_action :authorize_trade_participant, only: [:show, :update]

  # GET /api/v1/trades
  def index
    trades = Trade.includes(:proposer, :receiver, :proposer_item, :receiver_item)
                  .for_user(current_user.id)
                  .recent
    
    trades = trades.where(status: params[:status]) if params[:status].present?
    
    render json: trades.map { |trade| trade_response(trade) }, status: :ok
  end

  # GET /api/v1/trades/:id
  def show
    render json: trade_detail_response(@trade), status: :ok
  end

  # POST /api/v1/trades
  def create
    trade = Trade.new(trade_create_params)
    trade.proposer = current_user
    trade.status = 'pending'
    
    if trade.save
      render json: trade_detail_response(trade), status: :created
    else
      render json: { errors: trade.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/trades/:id
  def update
    action = params[:action_type]
    
    case action
    when 'accept'
      if @trade.receiver_id == current_user.id && @trade.status == 'pending'
        if @trade.accept!
          render json: trade_detail_response(@trade), status: :ok
        else
          render json: { errors: @trade.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot accept this trade' }, status: :forbidden
      end
    when 'reject'
      if @trade.receiver_id == current_user.id && @trade.status == 'pending'
        if @trade.reject!
          render json: trade_detail_response(@trade), status: :ok
        else
          render json: { errors: @trade.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot reject this trade' }, status: :forbidden
      end
    when 'cancel'
      if @trade.proposer_id == current_user.id && @trade.status == 'pending'
        if @trade.cancel!
          render json: trade_detail_response(@trade), status: :ok
        else
          render json: { errors: @trade.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot cancel this trade' }, status: :forbidden
      end
    when 'complete'
      if @trade.status == 'accepted'
        if @trade.complete!
          render json: trade_detail_response(@trade), status: :ok
        else
          render json: { errors: @trade.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot complete this trade' }, status: :forbidden
      end
    else
      render json: { error: 'Invalid action' }, status: :bad_request
    end
  end

  private

  def set_trade
    @trade = Trade.includes(:proposer, :receiver, :proposer_item, :receiver_item).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trade not found' }, status: :not_found
  end

  def authorize_trade_participant
    unless @trade.proposer_id == current_user.id || @trade.receiver_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end

  def trade_create_params
    params.require(:trade).permit(:receiver_id, :proposer_item_id, :receiver_item_id)
  end

  def trade_response(trade)
    {
      id: trade.id,
      status: trade.status,
      proposer: {
        id: trade.proposer.id,
        name: trade.proposer.name,
        picture: trade.proposer.picture
      },
      receiver: {
        id: trade.receiver.id,
        name: trade.receiver.name,
        picture: trade.receiver.picture
      },
      proposer_item: {
        id: trade.proposer_item.id,
        title: trade.proposer_item.title
      },
      receiver_item: {
        id: trade.receiver_item.id,
        title: trade.receiver_item.title
      },
      created_at: trade.created_at,
      updated_at: trade.updated_at
    }
  end

  def trade_detail_response(trade)
    {
      id: trade.id,
      status: trade.status,
      proposer: {
        id: trade.proposer.id,
        name: trade.proposer.name,
        email: trade.proposer.email,
        picture: trade.proposer.picture
      },
      receiver: {
        id: trade.receiver.id,
        name: trade.receiver.name,
        email: trade.receiver.email,
        picture: trade.receiver.picture
      },
      proposer_item: {
        id: trade.proposer_item.id,
        title: trade.proposer_item.title,
        description: trade.proposer_item.description,
        images: trade.proposer_item.item_images.map { |img| { url: img.image_url, position: img.position } }
      },
      receiver_item: {
        id: trade.receiver_item.id,
        title: trade.receiver_item.title,
        description: trade.receiver_item.description,
        images: trade.receiver_item.item_images.map { |img| { url: img.image_url, position: img.position } }
      },
      created_at: trade.created_at,
      updated_at: trade.updated_at
    }
  end
end
