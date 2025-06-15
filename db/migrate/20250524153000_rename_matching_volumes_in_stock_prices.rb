class RenameMatchingVolumesInStockPrices < ActiveRecord::Migration[7.0]
  def change
    rename_column :stock_prices, :matching_volume_foreign, :volume_foreign_matching
    rename_column :stock_prices, :matching_volume_self, :volume_self_matching
  end
end
