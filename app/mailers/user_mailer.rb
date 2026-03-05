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

  def password_reset_email(user)
    I18n.with_locale(user.language) do
      @user = user
      @frontend_url = ENV['FRONTEND_URL'] || 'http://localhost:5173'
      @reset_url = "#{@frontend_url}/reset-password?token=#{@user.reset_password_token}"

      mail(
        to: @user.email,
        subject: I18n.t('user_mailer.password_reset_email.subject')
      )
    end
  end
end
