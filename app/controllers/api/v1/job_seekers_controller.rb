class Api::V1::JobSeekersController < Api::V1::BaseController
  def index
    @job_seekers = JobSeeker.all
    render json: @job_seekers
  end

  def show
    @job_seeker = JobSeeker.find(params[:id])
    render json: @job_seeker
  end

  def create
    @job_seeker = JobSeeker.new(job_seeker_params)
    if @job_seeker.save
      render json: @job_seeker, status: :created
    else
      render json: @job_seeker.errors, status: :unprocessable_entity
    end
  end

  def update
    @job_seeker = JobSeeker.find(params[:id])
    if @job_seeker.update(job_seeker_params)
      render json: @job_seeker
    else
      render json: @job_seeker.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @job_seeker = JobSeeker.find(params[:id])
    @job_seeker.destroy
    head :no_content
  end

  private

  def job_seeker_params
    params.require(:job_seeker).permit(:name, :email, :resume)
  end
end
