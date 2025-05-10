class CreateStockRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_records do |t|
      t.string :hashkey
      t.references :ticker, null: false, foreign_key: true
      t.date :date
      t.decimal :price
      t.decimal :change_percent
      t.decimal :vol_td
      t.decimal :khop_td
      t.decimal :vol_nn
      t.decimal :khop_nn
      t.decimal :so_huu_nn
      t.decimal :rate_nn
      t.decimal :rate_td
      t.decimal :day_vol
      t.decimal :day_trade
      t.decimal :max_percent_nn

      t.timestamps
    end
  end
end
