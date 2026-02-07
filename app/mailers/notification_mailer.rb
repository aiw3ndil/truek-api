class NotificationMailer < ApplicationMailer
  def new_notification_email
    @notification = params[:notification]

    mail(
      to: @notification.user.email,
      subject: @notification.title
    ) do |format|
      format.html { render 'new_notification_email' }
      format.text { render plain: 'new_notification_email' }
    end
  end
end
