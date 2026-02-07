class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_current_user

  private

  def set_current_user
    Current.user = current_user if respond_to?(:current_user)
  end
end
