class Api::V1::JobApplicationsController < Api::V1::BaseController
  def index
    @job_seeker = JobSeeker.find(params[:job_seeker_id])
    @job_applications = @job_seeker.job_applications
    render json: @job_applications
  end

  def show
    @job_application = JobApplication.find(params[:id])
    render json: @job_application
  end

  def create
    @job_seeker = JobSeeker.find(params[:job_seeker_id])
    @job_application = @job_seeker.job_applications.build(job_application_params)
    if @job_application.save
      render json: @job_application, status: :created
    else
      render json: @job_application.errors, status: :unprocessable_entity
    end
  end

  def update
    @job_application = JobApplication.find(params[:id])
    if @job_application.update(job_application_params)
      render json: @job_application
    else
      render json: @job_application.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @job_application = JobApplication.find(params[:id])
    @job_application.destroy
    head :no_content
  end

  private

  def job_application_params
    params.require(:job_application).permit(:status, :job_id)
  end
end
