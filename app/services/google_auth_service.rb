class GoogleAuthService
  def self.verify_token(token)
    begin
      validator = GoogleIDToken::Validator.new
      payload = validator.check(token, ENV['GOOGLE_CLIENT_ID'])
      
      return nil unless payload
      
      {
        sub: payload['sub'],
        email: payload['email'],
        name: payload['name'],
        picture: payload['picture'],
        email_verified: payload['email_verified']
      }
    rescue GoogleIDToken::ValidationError, JSON::ParserError => e
      Rails.logger.error("Google token validation error: #{e.message}")
      nil
    end
  end
end
