class Message < ApplicationRecord
  belongs_to :trade
  belongs_to :user

  validates :content, presence: true
end
