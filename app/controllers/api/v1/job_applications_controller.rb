class Api::V1::JobApplicationsController < Api::V1::BaseController
  before_action :set_job_application, only: [:show, :update, :destroy]
  before_action :authorize_job_application, only: [:show, :update, :destroy]

  def index
    if current_user.company?
      @job_applications = JobApplication.includes(:job, :job_seeker)
                                        .joins(:job)
                                        .where(jobs: { company_id: current_user.company.id })
    elsif current_user.job_seeker?
      @job_applications = current_user.job_seeker.job_applications.includes(:job)
    else
      @job_applications = JobApplication.includes(:job, :job_seeker)
    end

    @job_applications = @job_applications.by_status(params[:status]) if params[:status].present?
    @job_applications = @job_applications.recent if params[:sort] == 'recent'
    
    @job_applications = paginate(@job_applications)
    
    render_success({
      job_applications: @job_applications.map { |app| job_application_serializer(app) },
      pagination: {
        current_page: @job_applications.current_page,
        total_pages: @job_applications.total_pages,
        total_count: @job_applications.total_count,
        per_page: @job_applications.limit_value
      }
    })
  end

  def show
    render_success(job_application_serializer(@job_application))
  end

  def create
    @job = Job.find(params[:job_id])
    
    unless @job.can_apply?(current_user.job_seeker)
      return render_error('Cannot apply for this job', :unprocessable_entity)
    end

    @job_application = current_user.job_seeker.job_applications.build(
      job: @job,
      cover_letter: params[:cover_letter],
      status: 'pending',
      applied_at: Time.current
    )
    
    if @job_application.save
      render_success(job_application_serializer(@job_application), 'Application submitted successfully', :created)
    else
      render_error(@job_application.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  def update
    if @job_application.update(job_application_params)
      render_success(job_application_serializer(@job_application), 'Application updated successfully')
    else
      render_error(@job_application.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  def destroy
    if @job_application.can_withdraw?
      @job_application.update(status: 'withdrawn')
      render_success(nil, 'Application withdrawn successfully')
    else
      render_error('Cannot withdraw this application', :unprocessable_entity)
    end
  end

  private

  def set_job_application
    @job_application = JobApplication.find(params[:id])
  end

  def authorize_job_application
    authorize @job_application
  end

  def job_application_params
    params.require(:job_application).permit(:status, :cover_letter)
  end

  def job_application_serializer(application)
    {
      id: application.id,
      cover_letter: application.cover_letter,
      status: application.status,
      applied_at: application.applied_at,
      days_since_applied: application.days_since_applied,
      is_recent_application: application.is_recent_application?,
      job: {
        id: application.job.id,
        title: application.job.title,
        company: application.job.company.name,
        location: application.job.location,
        employment_type: application.job.employment_type
      },
      job_seeker: {
        id: application.job_seeker.id,
        name: application.job_seeker.full_name,
        location: application.job_seeker.location,
        experience_years: application.job_seeker.experience_years
      },
      created_at: application.created_at,
      updated_at: application.updated_at
    }
  end
end
