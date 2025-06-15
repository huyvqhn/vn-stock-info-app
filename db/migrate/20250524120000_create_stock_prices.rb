class CreateStockPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :stock_prices do |t|
      t.references :ticker, null: false, foreign_key: true
      t.decimal :price, precision: 15, scale: 2, null: false
      t.bigint :volume, null: false
      t.decimal :percent_change, precision: 6, scale: 2
      t.bigint :matching_volume_foreign
      t.bigint :matching_volume_self
      t.date :recorded_at, null: false
      t.decimal :beta, precision: 8, scale: 4
      t.decimal :dividend_yield_ttm, precision: 8, scale: 4

      t.timestamps
    end
    add_index :stock_prices, [:ticker_id, :recorded_at], unique: true
  end
end
