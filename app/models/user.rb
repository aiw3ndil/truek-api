class User < ApplicationRecord
  has_secure_password validations: false
  
  has_many :items, dependent: :destroy
  has_many :proposed_trades, class_name: 'Trade', foreign_key: 'proposer_id', dependent: :destroy
  has_many :received_trades, class_name: 'Trade', foreign_key: 'receiver_id', dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { password_required? }
  validate :password_confirmation_match, if: -> { password_required? }
  validates :google_id, uniqueness: true, allow_nil: true
  validates :provider, inclusion: { in: %w[email google] }

  before_save :downcase_email

  def self.from_google(google_data)
    user = find_or_initialize_by(email: google_data[:email].downcase)
    
    if user.new_record?
      user.assign_attributes(
        google_id: google_data[:sub],
        name: google_data[:name],
        picture: google_data[:picture],
        provider: 'google'
      )
      user.save(validate: false)
    elsif user.google_id.nil?
      user.update_columns(
        google_id: google_data[:sub],
        picture: google_data[:picture],
        provider: 'google'
      )
    end
    
    user
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def password_required?
    provider == 'email' && (new_record? || !password.nil?)
  end

  def password_confirmation_match
    if password.present? && password != password_confirmation
      errors.add(:password_confirmation, "doesn't match Password")
    end
  end
end
