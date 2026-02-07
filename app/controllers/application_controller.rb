class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_current_user
  before_action :set_locale

  private

  def set_current_user
    Current.user = current_user if respond_to?(:current_user)
  end

  def set_locale
    I18n.locale = Current.user&.language&.to_sym || I18n.default_locale
  end
end
