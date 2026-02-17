class Notification < ApplicationRecord
  belongs_to :user

  validates :title, :message, :notification_type, presence: true
  
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :send_email

  private

  def send_email
    email_notification_types = %w[trade_requested trade_accepted new_message trade_cancelled]
    if email_notification_types.include?(notification_type)
      NotificationMailer.with(notification: self).new_notification_email.deliver_later
    end
  end
end
