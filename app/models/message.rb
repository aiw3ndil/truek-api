class Message < ApplicationRecord
  belongs_to :trade
  belongs_to :user

  validates :content, presence: true

  after_create_commit :notify_recipient

  private

  def notify_recipient
    recipient = (trade.proposer_id == user_id) ? trade.receiver : trade.proposer
    
    I18n.with_locale(recipient.language) do
      Notification.create(
        user: recipient,
        title: I18n.t('notifications.new_message.title'),
        message: I18n.t('notifications.new_message.message', sender_name: user.name),
        link: "/trades", # Or specific chat link if implemented
        notification_type: "new_message"
      )
    end
  end
end
