class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_application, only: [:show, :update, :destroy]
  before_action :authorize_job_application, only: [:show, :update, :destroy]

  def index
    if current_user.job_seeker?
      @job_applications = current_user.job_seeker.job_applications.includes(:job, :job => :company)
    elsif current_user.company?
      # Get all applications for jobs posted by this company
      @job_applications = JobApplication.joins(:job)
                                      .where(jobs: { company_id: current_user.company.id })
                                      .includes(:job_seeker, :job)
    else
      @job_applications = JobApplication.includes(:job, :job_seeker, :job => :company)
    end
    
    @job_applications = @job_applications.order(created_at: :desc)
  end

  def show
  end

  def create
    @job = Job.find(params[:job_id])
    @job_application = @job.job_applications.build(job_application_params)
    @job_application.job_seeker = current_user.job_seeker
    
    respond_to do |format|
      if @job_application.save
        format.html { redirect_to @job, notice: 'Application submitted successfully.' }
        format.turbo_stream { render turbo_stream: turbo_stream.prepend('applications', partial: 'job_applications/job_application', locals: { job_application: @job_application }) }
      else
        format.html { redirect_to @job, alert: 'Failed to submit application.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('application_form', partial: 'job_applications/form', locals: { job_application: @job_application }) }
      end
    end
  end

  def update
    respond_to do |format|
      if @job_application.update(job_application_params)
        format.html { redirect_to @job_application, notice: 'Application was successfully updated.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("job_application_#{@job_application.id}", partial: 'job_applications/job_application', locals: { job_application: @job_application }) }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('application_form', partial: 'job_applications/form', locals: { job_application: @job_application }) }
      end
    end
  end

  def destroy
    @job_application.destroy
    
    respond_to do |format|
      format.html { redirect_to job_applications_url, notice: 'Application was successfully deleted.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("job_application_#{@job_application.id}") }
    end
  end

  private

  def set_job_application
    @job_application = JobApplication.find(params[:id])
  end

  def authorize_job_application
    # Allow job seekers to view their own applications
    # Allow companies to view applications for their jobs
    # Allow admins to view all applications
    unless current_user.admin? || 
           (current_user.job_seeker? && @job_application.job_seeker == current_user.job_seeker) ||
           (current_user.company? && @job_application.job.company == current_user.company)
      redirect_to root_path, alert: 'You are not authorized to view this application.'
    end
  end

  def job_application_params
    params.require(:job_application).permit(:cover_letter, :status)
  end
end
