class AddVolumeChangePctToStockTradingDays < ActiveRecord::Migration[7.1]
  def change
    add_column :stock_trading_days, :volume_change_pct, :float
  end
end
