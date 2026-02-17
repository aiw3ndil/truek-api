class Item < ApplicationRecord
  belongs_to :user
  has_many :item_images, dependent: :destroy
  has_many :trades_as_proposer, class_name: 'Trade', foreign_key: 'proposer_item_id'
  has_many :trades_as_receiver, class_name: 'Trade', foreign_key: 'receiver_item_id'
  
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :status, presence: true, inclusion: { in: %w[available traded unavailable] }

  before_validation :set_region_from_user, on: :create
  before_destroy :handle_associated_trades
  
  accepts_nested_attributes_for :item_images, allow_destroy: true
  
  scope :available, -> { where(status: 'available') }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :search_by_title, ->(query) { where('LOWER(title) LIKE ?', "%#{query.downcase}%") }
  
  def traded?
    status == 'traded'
  end
  
  def available?
    status == 'available'
  end

  private

  def handle_associated_trades
    trades = Trade.where('proposer_item_id = :id OR receiver_item_id = :id', id: id)
    
    trades.each do |trade|
      case trade.status
      when 'pending', 'accepted'
        errors.add(:base, 'Cannot delete item with active trades. Please cancel them first.')
        throw(:abort)
      when 'completed'
        errors.add(:base, 'Cannot delete item that is part of a completed trade.')
        throw(:abort)
      when 'rejected', 'cancelled'
        # These are safe to delete along with the item
        trade.destroy
      end
    end
  end

  def set_region_from_user
    self.region ||= user&.region
  end
end
