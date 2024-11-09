class Api::V1::UsersController < ApplicationController
  # skip_before_action :authorize_request, only: [ :signup, :login ]

  def signup
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      render json: { status: "success", message: "User successfully signed up", payload: { user_id: @user.id, token: token } }, status: :created
    else
      render json: { status: "error", message: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: user_params[:email])
    if @user&.authenticate(user_params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: { status: "success", message: "Login successful", payload: { token: token } }
    else
      render json: { status: "error", message: "Invalid credentials" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
