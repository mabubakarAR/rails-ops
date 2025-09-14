class Api::V1::JobsController < Api::V1::BaseController
  before_action :set_job, only: [:show, :update, :destroy]
  before_action :authorize_job, only: [:update, :destroy]

  def index
    @jobs = Job.includes(:company, :categories, :job_applications)
    
    @jobs = @jobs.active if params[:active_only] == 'true'
    @jobs = @jobs.by_location(params[:location]) if params[:location].present?
    @jobs = @jobs.by_employment_type(params[:employment_type]) if params[:employment_type].present?
    @jobs = @jobs.remote if params[:remote] == 'true'
    @jobs = @jobs.recent if params[:sort] == 'recent'
    
    if params[:salary_min].present? && params[:salary_max].present?
      @jobs = @jobs.where('salary_min >= ? AND salary_max <= ?', params[:salary_min], params[:salary_max])
    end
    
    if params[:search].present?
      @jobs = @jobs.where('title LIKE ? OR description LIKE ?', 
                         "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @jobs = paginate(@jobs)
    
    render_success({
      jobs: @jobs.map { |job| job_serializer(job) },
      pagination: {
        current_page: @jobs.current_page,
        total_pages: @jobs.total_pages,
        total_count: @jobs.total_count,
        per_page: @jobs.limit_value
      }
    })
  end

  def show
    render_success(job_serializer(@job))
  end

  def create
    @job = current_user.company.jobs.build(job_params)
    @job.status = 'draft'
    
    if @job.save
      render_success(job_serializer(@job), 'Job created successfully', :created)
    else
      render_error(@job.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  def update
    if @job.update(job_params)
      render_success(job_serializer(@job), 'Job updated successfully')
    else
      render_error(@job.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  def destroy
    @job.destroy
    render_success(nil, 'Job deleted successfully')
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def authorize_job
    authorize @job
  end

  def job_params
    params.require(:job).permit(
      :title, :description, :requirements, :benefits, :location,
      :salary_min, :salary_max, :employment_type, :remote, :status,
      category_ids: []
    )
  end

  def job_serializer(job)
    {
      id: job.id,
      title: job.title,
      description: job.description,
      requirements: job.requirements,
      benefits: job.benefits,
      location: job.location,
      salary_range: job.salary_range,
      employment_type: job.employment_type,
      remote: job.remote,
      status: job.status,
      days_since_posted: job.days_since_posted,
      is_recent: job.is_recent?,
      company: {
        id: job.company.id,
        name: job.company.name,
        industry: job.company.industry,
        size: job.company.size
      },
      categories: job.categories.map { |cat| { id: cat.id, name: cat.name } },
      total_applications: job.total_applications,
      created_at: job.created_at,
      updated_at: job.updated_at
    }
  end
end
