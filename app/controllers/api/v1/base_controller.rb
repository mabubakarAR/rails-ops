module Api
  module V1
    class BaseController < ActionController::API
      # Disable CSRF protection for all API endpoints
      # protect_from_forgery with: :null_session
    end
  end
end