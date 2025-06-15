class MoveBetaAndDividendYieldTtmToTickers < ActiveRecord::Migration[6.1]
  def change
    remove_column :stock_prices, :beta, :decimal, precision: 8, scale: 4
    remove_column :stock_prices, :dividend_yield_ttm, :decimal, precision: 8, scale: 4
    add_column :tickers, :beta, :decimal, precision: 8, scale: 4
    add_column :tickers, :dividend_yield_ttm, :decimal, precision: 8, scale: 4
  end
end
