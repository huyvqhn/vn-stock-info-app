class AddNetValuesToStockPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_prices, :value_self_net, :decimal, precision: 20, scale: 2
    add_column :stock_prices, :value_foreign_net, :decimal, precision: 20, scale: 2
    add_column :stock_prices, :value_total_net, :decimal, precision: 20, scale: 2
  end
end
