class Api::V1::ItemsController < ApplicationController
  include Authentication
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :authenticate_optional, only: [:index, :show]
  before_action :set_item, only: [:show, :update, :destroy]
  before_action :authorize_item_owner, only: [:update, :destroy]

  # GET /api/v1/items
  def index
    items = Item.includes(:user, item_images: { file_attachment: :blob }).available.recent

    # Filter by current user's region if a user is logged in
    if current_user
      items = items.where(region: current_user.region)
    end
    
    items = items.search_by_title(params[:query]) if params[:query].present?
    items = items.by_user(params[:user_id]) if params[:user_id].present?
    
    render json: items.map { |item| item_response(item) }, status: :ok
  end

  # GET /api/v1/items/:id
  def show
    render json: item_detail_response(@item), status: :ok
  end

  # POST /api/v1/items
  def create
    item = current_user.items.new(item_params)
    
    if item.save
      render json: item_detail_response(item), status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/items/:id
  def update
    if @item.update(item_params)
      render json: item_detail_response(@item), status: :ok
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/items/:id
  def destroy
    if @item.destroy
      head :no_content
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.includes(:user, item_images: { file_attachment: :blob }).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end

  def authorize_item_owner
    unless @item.user_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end

  def item_params
    params.require(:item).permit(
      :title, 
      :description, 
      :status,
      item_images_attributes: [:id, :file, :position, :_destroy]
    )
  end

  def item_response(item)
    {
      id: item.id,
      title: item.title,
      description: item.description,
      status: item.status,
      user: {
        id: item.user.id,
        name: item.user.name,
        picture: item.user.picture.attached? ? rails_blob_url(item.user.picture) : nil
      },
      images: item.item_images.map { |img| { id: img.id, url: img.file.attached? ? rails_blob_url(img.file) : nil, position: img.position } },
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end

  def item_detail_response(item)
    item_response(item)
  end
end
