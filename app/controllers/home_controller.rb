class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    if user_signed_in?
      case current_user.role
      when 'company'
        redirect_to companies_path
      when 'job_seeker'
        redirect_to jobs_path
      when 'admin'
        redirect_to admin_root_path
      else
        redirect_to jobs_path
      end
    else
      # Show landing page for non-authenticated users
      @recent_jobs = Job.active.limit(6).includes(:company)
      @companies_count = Company.count
      @jobs_count = Job.active.count
      @job_seekers_count = JobSeeker.count
    end
  end
end
