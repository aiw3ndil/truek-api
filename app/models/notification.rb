class Notification < ApplicationRecord
  belongs_to :user

  validates :title, :message, :notification_type, presence: true
  
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
end
