class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  # Ensure all mailer generated URLs are absolute
  if Rails.env.development?
    default_url_options[:host] = 'localhost'
    default_url_options[:port] = 3000
    default_url_options[:protocol] = 'http'
  else # Production/Staging etc.
    default_url_options[:host] = ENV['ACTION_MAILER_HOST'] || 'your_production_domain.com' # Fallback for clarity
    default_url_options[:port] = ENV['ACTION_MAILER_PORT'] # nil for default ports (80/443)
    default_url_options[:protocol] = ENV['ACTION_MAILER_PROTOCOL'] || 'https'
  end
end
