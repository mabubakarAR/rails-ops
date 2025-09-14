class JobSeekersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_seeker, only: [:show, :edit, :update, :destroy]
  before_action :ensure_job_seeker_user, only: [:new, :create, :edit, :update, :destroy]

  def index
    @job_seekers = JobSeeker.includes(:user, :job_applications)
    @job_seekers = @job_seekers.where("first_name ILIKE ? OR last_name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    @job_seekers = @job_seekers.limit(20)
  end

  def show
  end

  def new
    @job_seeker = current_user.build_job_seeker
  end

  def create
    @job_seeker = current_user.build_job_seeker(job_seeker_params)
    
    respond_to do |format|
      if @job_seeker.save
        format.html { redirect_to @job_seeker, notice: 'Profile was successfully created.' }
        format.turbo_stream { render turbo_stream: turbo_stream.prepend('job_seekers', partial: 'job_seekers/job_seeker', locals: { job_seeker: @job_seeker }) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('job_seeker_form', partial: 'job_seekers/form', locals: { job_seeker: @job_seeker }) }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @job_seeker.update(job_seeker_params)
        format.html { redirect_to @job_seeker, notice: 'Profile was successfully updated.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("job_seeker_#{@job_seeker.id}", partial: 'job_seekers/job_seeker', locals: { job_seeker: @job_seeker }) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('job_seeker_form', partial: 'job_seekers/form', locals: { job_seeker: @job_seeker }) }
      end
    end
  end

  def destroy
    @job_seeker.destroy
    
    respond_to do |format|
      format.html { redirect_to job_seekers_url, notice: 'Profile was successfully deleted.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("job_seeker_#{@job_seeker.id}") }
    end
  end

  private

  def set_job_seeker
    @job_seeker = JobSeeker.find(params[:id])
  end

  def ensure_job_seeker_user
    unless current_user.job_seeker?
      redirect_to root_path, alert: 'Only job seekers can manage job seeker profiles.'
    end
  end

  def job_seeker_params
    params.require(:job_seeker).permit(
      :first_name, :last_name, :phone, :location, :bio, 
      :experience_years, :resume
    )
  end
end
