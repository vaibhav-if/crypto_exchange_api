class ApplicationController < ActionController::API
  def authenticate_user!
    render json: { status: "error", message: "Not authorized" }, status: :unauthorized unless current_user
  end

  private
  def current_user
    @current_user ||= User.find(JsonWebToken.decode_token(request.headers["Authorization"]))
  end
end
