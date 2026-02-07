class Api::V1::NotificationsController < ApplicationController
  include Authentication
  before_action :set_notification, only: [:update, :destroy]

  # GET /api/v1/notifications
  def index
    notifications = current_user.notifications.recent
    render json: notifications.map { |n| notification_response(n) }, status: :ok
  end

  # PATCH/PUT /api/v1/notifications/:id
  def update
    if @notification.update(read: true)
      render json: notification_response(@notification), status: :ok
    else
      render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/notifications/:id
  def destroy
    @notification.destroy
    head :no_content
  end

  # POST /api/v1/notifications/mark_all_as_read
  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)
    head :no_content
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Notification not found' }, status: :not_found
  end

  def notification_response(notification)
    {
      id: notification.id,
      title: notification.title,
      message: notification.message,
      link: notification.link,
      read: notification.read,
      notification_type: notification.notification_type,
      created_at: notification.created_at
    }
  end
end
