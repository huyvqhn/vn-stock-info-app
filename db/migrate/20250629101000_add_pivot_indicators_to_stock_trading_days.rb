class AddPivotIndicatorsToStockTradingDays < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_trading_days, :indicator_pivot_foreign, :boolean, default: false
    add_column :stock_trading_days, :indicator_pivot_proprietary, :boolean, default: false
    add_column :stock_trading_days, :indicator_volume_spike, :boolean, default: false
    add_column :stock_trading_days, :indicator_candle_reversal, :boolean, default: false
  end
end
