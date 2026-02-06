class ItemImage < ApplicationRecord
  belongs_to :item
  
  has_one_attached :file
  
  validates :file, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  default_scope { order(position: :asc) }
end
