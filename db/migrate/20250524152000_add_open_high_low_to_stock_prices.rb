class AddOpenHighLowToStockPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_prices, :open, :decimal, precision: 15, scale: 2
    add_column :stock_prices, :high, :decimal, precision: 15, scale: 2
    add_column :stock_prices, :low, :decimal, precision: 15, scale: 2
  end
end
