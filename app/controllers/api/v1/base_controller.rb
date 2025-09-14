class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :set_default_response_format

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  private

  def set_default_response_format
    request.format = :json
  end

  def record_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end

  def record_invalid(exception)
    render json: { 
      error: 'Validation failed', 
      details: exception.record.errors.full_messages 
    }, status: :unprocessable_entity
  end

  def not_authorized
    render json: { error: 'Not authorized' }, status: :forbidden
  end

  def render_success(data = nil, message = 'Success', status = :ok)
    response = { message: message }
    response[:data] = data if data
    render json: response, status: status
  end

  def render_error(message = 'Error', status = :bad_request)
    render json: { error: message }, status: status
  end

  def paginate(collection, per_page = 20)
    page = params[:page] || 1
    collection.page(page).per(per_page)
  end
end
