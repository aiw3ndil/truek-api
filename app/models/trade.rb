class Trade < ApplicationRecord
  belongs_to :proposer, class_name: 'User'
  belongs_to :proposer_item, class_name: 'Item'
  belongs_to :receiver, class_name: 'User'
  belongs_to :receiver_item, class_name: 'Item'
  
  has_many :messages, dependent: :destroy
  
  validates :status, presence: true, inclusion: { in: %w[pending accepted rejected cancelled completed] }
  validate :users_must_be_different
  validate :items_must_be_available, on: :create
  validate :users_must_own_items
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :for_user, ->(user_id) { where('proposer_id = ? OR receiver_id = ?', user_id, user_id) }
  scope :recent, -> { order(created_at: :desc) }
  
  after_create_commit :notify_receiver_of_suggestion
  after_update_commit :update_items_status, if: :saved_change_to_status?
  after_update_commit :notify_participants_of_status_change, if: :saved_change_to_status?

  def accept!(initiator)
    update(status: 'accepted')
    notify_participants_of_status_change(initiator)
  end
  
  def reject!(initiator)
    update(status: 'rejected')
    notify_participants_of_status_change(initiator)
  end
  
  def cancel!(initiator)
    update(status: 'cancelled')
    notify_participants_of_status_change(initiator)
  end
  
  def complete!(initiator)
    transaction do
      update!(status: 'completed')
      proposer_item.update!(status: 'traded')
      receiver_item.update!(status: 'traded')
    end
    notify_participants_of_status_change(initiator)
  end
  
  private
  
  def users_must_be_different
    errors.add(:base, 'Cannot trade with yourself') if proposer_id == receiver_id
  end
  
  def items_must_be_available
    errors.add(:proposer_item, 'must be available') unless proposer_item&.available?
    errors.add(:receiver_item, 'must be available') unless receiver_item&.available?
  end
  
  def users_must_own_items
    errors.add(:proposer_item, 'must belong to proposer') unless proposer_item&.user_id == proposer_id
    errors.add(:receiver_item, 'must belong to receiver') unless receiver_item&.user_id == receiver_id
  end
  
  def update_items_status
    if status == 'completed'
      proposer_item.update(status: 'traded')
      receiver_item.update(status: 'traded')
    elsif status_before_last_save == 'accepted' && %w[cancelled rejected].include?(status)
      proposer_item.update(status: 'available')
      receiver_item.update(status: 'available')
    end
  end

  def notify_receiver_of_suggestion
    I18n.with_locale(receiver.language) do
      Notification.create(
        user: receiver,
        title: I18n.t('notifications.trade_requested.title'),
        message: I18n.t('notifications.trade_requested.message', proposer_name: proposer.name, proposer_item_title: proposer_item.title, receiver_item_title: receiver_item.title),
        link: "/trades",
        notification_type: "trade_requested"
      )
    end
  end

  def notify_participants_of_status_change(initiator)
    case status
    when 'accepted'
      # Notify proposer
      I18n.with_locale(proposer.language) do
        Notification.create(
          user: proposer,
          title: I18n.t('notifications.trade_accepted.title'),
          message: I18n.t('notifications.trade_accepted.message', receiver_name: receiver.name),
          link: "/trades",
          notification_type: "trade_accepted"
        )
      end
      # Notify receiver
      I18n.with_locale(receiver.language) do
        Notification.create(
          user: receiver,
          title: I18n.t('notifications.trade_accepted.title'),
          message: I18n.t('notifications.trade_accepted.message_receiver'),
          link: "/trades",
          notification_type: "trade_accepted"
        )
      end
    when 'rejected'
      I18n.with_locale(proposer.language) do
        Notification.create(
          user: proposer,
          title: I18n.t('notifications.trade_rejected.title'),
          message: I18n.t('notifications.trade_rejected.message', receiver_name: receiver.name),
          link: "/trades",
          notification_type: "trade_rejected"
        )
      end
    when 'cancelled'
      other_user = (initiator.id == proposer.id) ? receiver : proposer
      I18n.with_locale(other_user.language) do
        Notification.create(
          user: other_user,
          title: I18n.t('notifications.trade_cancelled.title'),
          message: I18n.t('notifications.trade_cancelled.message', initiator_name: initiator.name),
          link: "/trades",
          notification_type: "trade_cancelled"
        )
      end
    when 'completed'
      # Notify both
      [proposer, receiver].each do |user|
        I18n.with_locale(user.language) do
          Notification.create(
            user: user,
            title: I18n.t('notifications.trade_completed.title'),
            message: I18n.t('notifications.trade_completed.message'),
            link: "/trades",
            notification_type: "trade_completed"
          )
        end
      end
    end
  end
end
