class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    order = current_user.orders.new(order_params)
    if order.side == "sell"
      wallet = current_user.wallets.find_by(currency: order.base_currency)
      if wallet && wallet.balance >= order.volume
        wallet.balance -= order.volume
        wallet.save
        order.state = "pending"
        if order.save
          render json: {
            status: "success",
            message: "Successfully created",
            payload: order.attributes
          }, status: :created
        else
          render json: { status: "error", message: "Error creating order" }, status: :unprocessable_entity
        end
      else
        render json: { status: "error", message: "Insufficient funds" }, status: :unprocessable_entity
      end
    elsif order.side == "buy"
      wallet = current_user.wallets.find_by(currency: order.quote_currency)
      if wallet && wallet.balance >= order.price * order.volume
        wallet.balance -= order.price * order.volume
        wallet.save
        order.state = "pending"
        if order.save
          render json: {
            status: "success",
            message: "Successfully created",
            payload: order.attributes
          }, status: :created
        else
          render json: { status: "error", message: "Error creating order" }, status: :unprocessable_entity
        end
      else
        render json: { status: "error", message: "Insufficient funds" }, status: :unprocessable_entity
      end
    end
  end

  def cancel
    order = current_user.orders.find_by(id: params[:order_id])
    if order && order.state == "pending"
      order.state = "cancelled"
      order.save
      wallet = current_user.wallets.find_by(currency: order.base_currency)
      wallet.balance += order.volume if order.side == "sell"
      wallet.balance += order.price * order.volume if order.side == "buy"
      wallet.save
      render json: {
        status: "success",
        message: "Successfully cancelled",
        payload: {}
      }, status: :ok
    else
      render json: { status: "error", message: "Order not found or cannot be cancelled" }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:side, :base_currency, :quote_currency, :price, :volume)
  end
end
