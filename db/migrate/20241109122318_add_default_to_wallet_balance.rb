class AddDefaultToWalletBalance < ActiveRecord::Migration[8.0]
  def change
    change_column_default :wallets, :balance, 0.0
  end
end
