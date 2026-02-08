class User < ApplicationRecord
  has_secure_password validations: false
  
  has_one_attached :picture
  
  has_many :items, dependent: :destroy
  has_many :proposed_trades, class_name: 'Trade', foreign_key: 'proposer_id', dependent: :destroy
  has_many :receiver_trades, class_name: 'Trade', foreign_key: 'receiver_id'
  has_many :notifications, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { password_required? }
  validate :password_confirmation_match, if: -> { password_required? }
  validates :google_id, uniqueness: true, allow_nil: true
  validates :provider, inclusion: { in: %w[email google] }

  before_save :downcase_email
  before_save :set_region_from_language, if: -> { language_changed? || new_record? }
  after_create_commit :send_welcome_email

  scope :search_by_name, ->(query) { where('LOWER(name) LIKE ?', "%#{query.downcase}%") }

  def self.from_google(google_data)
    user = find_or_initialize_by(email: google_data[:email].downcase)

    if user.new_record?
      user.assign_attributes(
        google_id: google_data[:sub],
        name: google_data[:name],
        provider: 'google'
      )
      user.save(validate: false)
      user.attach_picture_from_url(google_data[:picture]) if google_data[:picture].present?
    elsif user.google_id.nil?
      user.update_columns(
        google_id: google_data[:sub],
        provider: 'google'
      )
      user.attach_picture_from_url(google_data[:picture]) if google_data[:picture].present?
    end
    
    user
  end

  def password_confirmation_match
    if password.present? && password != password_confirmation
      errors.add(:password_confirmation, "doesn't match Password")
    end
  end

  # Now public to be called from the class method `from_google`
  def attach_picture_from_url(picture_url)
    return unless picture_url.present?
    
    begin
      require 'open-uri'
      file = URI.open(picture_url)
      filename = File.basename(URI.parse(picture_url).path).presence || "picture.jpg"
      picture.attach(io: file, filename: filename)
    rescue => e
      Rails.logger.error("Failed to attach picture for user #{id}: #{e.message}")
    end
  end

  private

  def set_region_from_language
    # Simple mapping from language to region. This can be expanded later.
    self.region = self.language
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

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
