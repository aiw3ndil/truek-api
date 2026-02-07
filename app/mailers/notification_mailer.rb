class NotificationMailer < ApplicationMailer
  def new_notification_email
    @notification = params[:notification]
    # Manually construct the URL as a last resort
    protocol = default_url_options[:protocol] || 'http'
    host = default_url_options[:host] || 'localhost'
    port = default_url_options[:port]
    path = @notification.link
    @full_link_url = "#{protocol}://#{host}#{port ? ':' + port.to_s : ''}#{path}"

    mail(
      to: @notification.user.email,
      subject: @notification.title
    ) do |format|
      format.html { render 'new_notification_email' }
      format.text { render plain: 'new_notification_email' }
    end
  end
end
