class AddChangeToStockPricesAndRemoveTotalTrading < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_prices, :change, :decimal, precision: 15, scale: 2
    remove_column :stock_prices, :total_trading, :bigint
  end
end
