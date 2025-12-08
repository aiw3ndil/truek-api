class Item < ApplicationRecord
  belongs_to :user
  has_many :item_images, dependent: :destroy
  has_many :trades_as_proposer, class_name: 'Trade', foreign_key: 'proposer_item_id', dependent: :restrict_with_error
  has_many :trades_as_receiver, class_name: 'Trade', foreign_key: 'receiver_item_id', dependent: :restrict_with_error
  
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :status, presence: true, inclusion: { in: %w[available traded unavailable] }
  
  accepts_nested_attributes_for :item_images, allow_destroy: true
  
  scope :available, -> { where(status: 'available') }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  
  def traded?
    status == 'traded'
  end
  
  def available?
    status == 'available'
  end
end
