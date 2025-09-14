require 'rails_helper'

RSpec.describe JobApplicationNotificationJob, type: :job do
  let(:job_application) { create(:job_application) }

  describe '#perform' do
    context 'with new_application notification type' do
      it 'sends new application notification' do
        expect(JobApplicationMailer).to receive(:new_application_notification).with(job_application).and_return(double(deliver_now: true))
        
        JobApplicationNotificationJob.perform_now(job_application, 'new_application')
      end
    end

    context 'with status_update notification type' do
      it 'sends status update notification' do
        expect(JobApplicationMailer).to receive(:status_update_notification).with(job_application).and_return(double(deliver_now: true))
        
        JobApplicationNotificationJob.perform_now(job_application, 'status_update')
      end
    end
  end

  describe 'SMS notifications' do
    let(:company_user) { job_application.job.company.user }
    
    before do
      allow(Rails.application.credentials).to receive(:twilio).and_return(
        double(account_sid: 'test_sid', auth_token: 'test_token', phone_number: '+1234567890')
      )
      allow(Twilio::REST::Client).to receive(:new).and_return(
        double(messages: double(create: true))
      )
    end

    context 'when company user has phone number' do
      before { company_user.update(phone: '+1234567890') }

      it 'sends SMS notification for new application' do
        expect(Twilio::REST::Client).to receive(:new).and_return(
          double(messages: double(create: true))
        )
        
        JobApplicationNotificationJob.perform_now(job_application, 'new_application')
      end
    end

    context 'when company user has no phone number' do
      it 'does not send SMS notification' do
        expect(Twilio::REST::Client).not_to receive(:new)
        
        JobApplicationNotificationJob.perform_now(job_application, 'new_application')
      end
    end
  end
end
