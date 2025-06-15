class RenameVolumeAndAddVolumesToStockPrices < ActiveRecord::Migration[7.0]
  def change
    rename_column :stock_prices, :volume, :volume_total
    add_column :stock_prices, :volume_matching, :bigint
    add_column :stock_prices, :volume_deal, :bigint
  end
end
