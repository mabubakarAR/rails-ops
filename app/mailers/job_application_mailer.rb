class JobApplicationMailer < ApplicationMailer
  def new_application_notification(job_application)
    @job_application = job_application
    @company = job_application.job.company
    @job_seeker = job_application.job_seeker
    @job = job_application.job
    
    mail(
      to: @company.user.email,
      subject: "New Application for #{@job.title}"
    )
  end

  def status_update_notification(job_application)
    @job_application = job_application
    @company = job_application.job.company
    @job_seeker = job_application.job_seeker
    @job = job_application.job
    
    mail(
      to: @job_seeker.user.email,
      subject: "Application Status Update for #{@job.title}"
    )
  end
end
