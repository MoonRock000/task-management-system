class ApplicationController < ActionController::API
  rescue_from StandardError do |err|
    render json: { errors: [err] }, status: :internal_server_error
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: ['Unable to find the resource'] }, status: :not_found
  end
end
