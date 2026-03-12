class NotificationMailer < ApplicationMailer
  def new_notification_email
    @notification = params[:notification]
    path = @notification.link
    @full_link_url = root_url.chomp('/') + path

    mail(
      to: @notification.user.email,
      subject: @notification.title
    ) do |format|
      format.html { render 'new_notification_email' }
      format.text { render plain: 'new_notification_email' }
    end
  end
end
