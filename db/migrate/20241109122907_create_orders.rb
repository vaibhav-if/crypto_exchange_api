class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :side, null: false
      t.string :base_currency, null: false
      t.string :quote_currency, null: false
      t.decimal :price
      t.decimal :volume
      t.string :state

      t.timestamps
    end
  end
end
