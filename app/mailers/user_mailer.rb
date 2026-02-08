class UserMailer < ApplicationMailer
  def welcome_email(user)
    I18n.with_locale(user.language) do
      @user = user
      # Manually construct root_url string
      protocol = default_url_options[:protocol] || 'http'
      host = default_url_options[:host] || 'localhost'
      port = default_url_options[:port]
      @root_url = "#{protocol}://#{host}#{port ? ':' + port.to_s : ''}/"

      mail(
        to: @user.email,
        subject: I18n.t('user_mailer.welcome_email.subject')
      )
    end
  end
end
