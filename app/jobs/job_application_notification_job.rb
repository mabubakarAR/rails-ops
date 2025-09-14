class JobApplicationNotificationJob < ApplicationJob
  queue_as :default

  def perform(job_application, notification_type)
    case notification_type
    when 'new_application'
      send_new_application_notification(job_application)
    when 'status_update'
      send_status_update_notification(job_application)
    end
  end

  private

  def send_new_application_notification(job_application)
    company_user = job_application.job.company.user
    
    # Send email notification
    JobApplicationMailer.new_application_notification(job_application).deliver_now
    
    # Send SMS notification if phone number is available
    if company_user.phone.present?
      send_sms_notification(
        company_user.phone,
        "New job application received for #{job_application.job.title} from #{job_application.job_seeker.full_name}"
      )
    end
  end

  def send_status_update_notification(job_application)
    job_seeker_user = job_application.job_seeker.user
    
    # Send email notification
    JobApplicationMailer.status_update_notification(job_application).deliver_now
    
    # Send SMS notification if phone number is available
    if job_seeker_user.phone.present?
      send_sms_notification(
        job_seeker_user.phone,
        "Your application for #{job_application.job.title} status updated to #{job_application.status}"
      )
    end
  end

  def send_sms_notification(phone_number, message)
    return unless Rails.application.credentials.twilio&.account_sid.present?
    
    client = Twilio::REST::Client.new(
      Rails.application.credentials.twilio.account_sid,
      Rails.application.credentials.twilio.auth_token
    )
    
    client.messages.create(
      from: Rails.application.credentials.twilio.phone_number,
      to: phone_number,
      body: message
    )
  rescue Twilio::REST::RestError => e
    Rails.logger.error "SMS notification failed: #{e.message}"
  end
end
