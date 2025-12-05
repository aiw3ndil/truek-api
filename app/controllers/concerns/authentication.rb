module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id]) if decoded
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      @current_user = nil
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def authenticate_optional
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id]) if decoded
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      @current_user = nil
    end
  end
end
