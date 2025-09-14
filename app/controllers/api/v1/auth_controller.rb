class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:login, :register]
  skip_before_action :set_default_response_format, only: [:login, :register]

  def login
    user = User.find_by(email: params[:email])
    
    if user&.valid_password?(params[:password])
      token = generate_jwt_token(user)
      render json: {
        message: 'Login successful',
        data: {
          user: user_serializer(user),
          token: token
        }
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def register
    user = User.new(user_params)
    user.role = params[:role] || 'job_seeker'
    
    if user.save
      create_user_profile(user)
      token = generate_jwt_token(user)
      render json: {
        message: 'Registration successful',
        data: {
          user: user_serializer(user),
          token: token
        }
      }, status: :created
    else
      render json: { 
        error: 'Registration failed', 
        details: user.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def logout
    # In a JWT implementation, logout is typically handled client-side
    # by removing the token from storage
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  def profile
    render_success(user_serializer(current_user))
  end

  def update_profile
    if current_user.update(user_params)
      render_success(user_serializer(current_user), 'Profile updated successfully')
    else
      render_error(current_user.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def create_user_profile(user)
    case user.role
    when 'company'
      user.create_company(
        name: params[:company_name] || '',
        description: params[:company_description] || '',
        industry: params[:industry] || '',
        size: params[:size] || 'startup'
      )
    when 'job_seeker'
      user.create_job_seeker(
        first_name: params[:first_name] || '',
        last_name: params[:last_name] || '',
        location: params[:location] || '',
        bio: params[:bio] || ''
      )
    end
  end

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      role: user.role,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def user_serializer(user)
    {
      id: user.id,
      email: user.email,
      role: user.role,
      full_name: user.full_name,
      profile_complete: user.profile_complete?,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
