class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end
  
  def after_sign_in_path_for(resource)
    case resource.role
    when 'company'
      if resource.company.present?
        companies_path
      else
        new_company_path
      end
    when 'job_seeker'
      if resource.job_seeker.present?
        jobs_path
      else
        new_job_seeker_path
      end
    when 'admin'
      admin_root_path
    else
      root_path
    end
  end
  
  def after_sign_up_path_for(resource)
    case resource.role
    when 'company'
      new_company_path
    when 'job_seeker'
      new_job_seeker_path
    else
      root_path
    end
  end
end
