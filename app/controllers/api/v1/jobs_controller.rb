class Api::V1::JobsController < Api::V1::BaseController
  def index
    @company = Company.find(params[:company_id])
    @jobs = @company.jobs
    render json: @jobs
  end

  def show
    @job = Job.find(params[:id])
    render json: @job
  end

  def create
    @company = Company.find(params[:company_id])
    @job = @company.jobs.build(job_params)
    if @job.save
      render json: @job, status: :created
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  def update
    @job = Job.find(params[:id])
    if @job.update(job_params)
      render json: @job
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    head :no_content
  end

  private

  def job_params
    params.require(:job).permit(:title, :description, :location, :salary)
  end
end
