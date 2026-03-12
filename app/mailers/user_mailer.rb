class UserMailer < ApplicationMailer
  def welcome_email(user)
    I18n.with_locale(user.language) do
      @user = user
      @root_url = root_url

      mail(
        to: @user.email,
        subject: I18n.t('user_mailer.welcome_email.subject')
      )
    end
  end

  def password_reset_email(user)
    I18n.with_locale(user.language) do
      @user = user
      @frontend_url = Rails.configuration.x.frontend_url
      @reset_url = "#{@frontend_url}/reset-password?token=#{@user.reset_password_token}"

      mail(
        to: @user.email,
        subject: I18n.t('user_mailer.password_reset_email.subject')
      )
    end
  end
end
