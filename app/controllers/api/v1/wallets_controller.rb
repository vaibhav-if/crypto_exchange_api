class Api::V1::WalletsController < ApplicationController
  before_action :authenticate_user!

  def deposit
    wallet = current_user.wallets.find_or_create_by(currency: params[:currency])
    if params[:amount].to_d > 0.0
      wallet.balance += params[:amount].to_d
      if wallet.save
        render json: { status: "success", msg: "Successfully deposited funds", payload: { balance: wallet.balance, currency: wallet.currency }
        }, status: :ok
      else
        render json: { status: "error", msg: "Error depositing funds" }, status: :unprocessable_entity
      end
    else
      render json: { status: "error", msg: "Error depositing funds" }, status: :unprocessable_entity
    end
  end

  def withdrawal
    wallet = current_user.wallets.find_by(currency: params[:currency])
    if params[:amount].to_d > 0.0 && wallet && wallet.balance >= params[:amount].to_d
      wallet.balance -= params[:amount].to_d
      if wallet.save
        render json: { status: "success", msg: "Successfully withdrawn funds", payload: { balance: wallet.balance, currency: wallet.currency }
        }, status: :ok
      else
        render json: { status: "error", msg: "Error withdrawing funds" }, status: :unprocessable_entity
      end
    else
      render json: { status: "error", msg: "Insufficient funds" }, status: :unprocessable_entity
    end
  end

  def balances
    wallets = current_user.wallets
    render json: { status: "success", msg: "Successfully fetched funds", payload: wallets.map { |w| { balance: w.balance, currency: w.currency } }
    }, status: :ok
  end
end
