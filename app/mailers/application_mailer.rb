class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@truek.xyz"
  layout "mailer"
  include Rails.application.routes.url_helpers

  # Ensure all mailer generated URLs are absolute
  # default_url_options should be configured in config/environments/*.rb
end
