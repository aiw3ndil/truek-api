class UserMailer < ApplicationMailer
  def welcome_email(user)
    I18n.with_locale(user.language) do
      @user = user
      mail(
        to: @user.email,
        subject: I18n.t('user_mailer.welcome_email.subject')
      )
    end
  end
end
