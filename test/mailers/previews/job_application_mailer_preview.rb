# Preview all emails at http://localhost:3000/rails/mailers/job_application_mailer
class JobApplicationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/job_application_mailer/new_application_notification
  def new_application_notification
    JobApplicationMailer.new_application_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/job_application_mailer/status_update_notification
  def status_update_notification
    JobApplicationMailer.status_update_notification
  end
end
