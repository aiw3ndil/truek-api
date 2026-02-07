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
  
  after_update :update_items_status, if: :saved_change_to_status?
  
  def accept!
    update(status: 'accepted')
  end
  
  def reject!
    update(status: 'rejected')
  end
  
  def cancel!
    update(status: 'cancelled')
  end
  
  def complete!
    transaction do
      update!(status: 'completed')
      proposer_item.update!(status: 'traded')
      receiver_item.update!(status: 'traded')
    end
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
    elsif status == 'accepted' && status_before_last_save == 'pending'
      messages.create(user: proposer, content: "Intercambio aceptado. ¡Ya podéis hablar!")
    elsif status_before_last_save == 'accepted' && %w[cancelled rejected].include?(status)
      proposer_item.update(status: 'available')
      receiver_item.update(status: 'available')
    end
  end
end
