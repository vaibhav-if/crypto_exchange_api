class Api::V1::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_user!

  def index
    from_time = params[:from_time]
    to_time = params[:to_time]

    orders = Order.where(created_at: from_time..to_time)
    volume_by_currency = {}

    orders.each do |order|
      if order.side == "buy"
        volume_by_currency[order.quote_currency] ||= 0
        volume_by_currency[order.quote_currency] += order.price * order.volume
      else
        volume_by_currency[order.base_currency] ||= 0
        volume_by_currency[order.base_currency] += order.volume
      end
    end

    render json: { status: "success", message: "Data fetched successfully", payload: volume_by_currency }, status: :ok
  end

  private

  def ensure_admin_user!
    unless current_user.role == "admin"
      render json: { status: "error", message: "Not authorized" }, status: :unauthorized
    end
  end
end
