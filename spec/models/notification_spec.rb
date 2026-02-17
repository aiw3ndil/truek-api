require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'callbacks' do
    let(:user) { create(:user) }

    context 'after_create_commit' do
      it 'enqueues an email for specific notification types' do
        notification = build(:notification, user: user, notification_type: 'trade_requested')
        expect { notification.save }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it 'does not enqueue an email for other notification types' do
        notification = build(:notification, user: user, notification_type: 'welcome')
        expect { notification.save }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end
end
