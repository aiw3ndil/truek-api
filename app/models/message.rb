class Message < ApplicationRecord
  belongs_to :trade
  belongs_to :user

  validates :content, presence: true

  after_create_commit :notify_recipient

  private

  def notify_recipient
    # The message belongs to a trade
    recipient = (trade.proposer_id == user_id) ? trade.receiver : trade.proposer
    
    Notification.create(
      user: recipient,
      title: "Nuevo mensaje",
      message: "Has recibido un mensaje de #{user.name} sobre vuestro trueque.",
      link: "/trades", # Or specific chat link if implemented
      notification_type: "new_message"
    )
  end
end
