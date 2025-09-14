class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = Job.includes(:company, :categories, :job_applications)
    
    @jobs = @jobs.active if params[:active_only] == 'true'
    @jobs = @jobs.by_location(params[:location]) if params[:location].present?
    @jobs = @jobs.by_employment_type(params[:employment_type]) if params[:employment_type].present?
    @jobs = @jobs.remote if params[:remote] == 'true'
    @jobs = @jobs.recent if params[:sort] == 'recent'
    
    if params[:search].present?
      @jobs = @jobs.where('title ILIKE ? OR description ILIKE ?', 
                         "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @jobs = @jobs.limit(20)
  end

  def show
    @job_application = @job.job_applications.build
  end

  def new
    if current_user.company? && current_user.company.present?
      @job = current_user.company.jobs.build
    else
      redirect_to new_company_path, alert: 'Please create a company profile first.'
    end
  end

  def create
    if current_user.company? && current_user.company.present?
      @job = current_user.company.jobs.build(job_params)
      @job.status = 'draft'
      
      respond_to do |format|
        if @job.save
          format.html { redirect_to @job, notice: 'Job was successfully created.' }
          format.turbo_stream { render turbo_stream: turbo_stream.prepend('jobs', partial: 'jobs/job', locals: { job: @job }) }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace('job_form', partial: 'jobs/form', locals: { job: @job }) }
        end
      end
    else
      redirect_to new_company_path, alert: 'Please create a company profile first.'
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("job_#{@job.id}", partial: 'jobs/job', locals: { job: @job }) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('job_form', partial: 'jobs/form', locals: { job: @job }) }
      end
    end
  end

  def destroy
    @job.destroy
    
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully deleted.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("job_#{@job.id}") }
    end
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end


  def job_params
    params.require(:job).permit(
      :title, :description, :requirements, :benefits, :location,
      :salary_min, :salary_max, :employment_type, :remote, :status,
      category_ids: []
    )
  end
end
