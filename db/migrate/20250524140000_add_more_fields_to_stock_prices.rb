class AddMoreFieldsToStockPrices < ActiveRecord::Migration[6.1]
  def change
    add_column :stock_prices, :average_price, :decimal, precision: 15, scale: 2
    add_column :stock_prices, :total_trading, :bigint
    add_column :stock_prices, :total_trading_value, :decimal, precision: 20, scale: 2
    add_column :stock_prices, :foreign_room, :bigint
    add_column :stock_prices, :foreign_remain, :bigint
  end
end
