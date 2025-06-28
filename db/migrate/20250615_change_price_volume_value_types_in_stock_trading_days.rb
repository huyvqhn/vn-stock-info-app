class ChangePriceVolumeValueTypesInStockTradingDays < ActiveRecord::Migration[7.0]
  def up
    # Price columns to integer
    change_column :stock_trading_days, :price_close, :integer, using: 'price_close::integer'
    change_column :stock_trading_days, :price_change, :integer, using: 'price_change::integer'
    change_column :stock_trading_days, :price_open, :integer, using: 'price_open::integer'
    change_column :stock_trading_days, :price_high, :integer, using: 'price_high::integer'
    change_column :stock_trading_days, :price_low, :integer, using: 'price_low::integer'
    change_column :stock_trading_days, :price_average, :integer, using: 'price_average::integer'

    # Volume columns to integer
    change_column :stock_trading_days, :volume_total, :integer, using: 'volume_total::integer'
    change_column :stock_trading_days, :volume_match, :integer, using: 'volume_match::integer'
    change_column :stock_trading_days, :volume_negotiated, :integer, using: 'volume_negotiated::integer'
    change_column :stock_trading_days, :volume_foreign_net, :integer, using: 'volume_foreign_net::integer'
    change_column :stock_trading_days, :volume_foreign_buy, :integer, using: 'volume_foreign_buy::integer'
    change_column :stock_trading_days, :volume_foreign_sell, :integer, using: 'volume_foreign_sell::integer'
    change_column :stock_trading_days, :volume_proprietary_net, :integer, using: 'volume_proprietary_net::integer'
    change_column :stock_trading_days, :volume_proprietary_buy, :integer, using: 'volume_proprietary_buy::integer'
    change_column :stock_trading_days, :volume_proprietary_sell, :integer, using: 'volume_proprietary_sell::integer'

    # Value columns to bigint
    change_column :stock_trading_days, :value_total, :bigint, using: 'value_total::bigint'
    change_column :stock_trading_days, :value_match, :bigint, using: 'value_match::bigint'
    change_column :stock_trading_days, :value_negotiated, :bigint, using: 'value_negotiated::bigint'
    change_column :stock_trading_days, :value_foreign_net, :bigint, using: 'value_foreign_net::bigint'
    change_column :stock_trading_days, :value_proprietary_net, :bigint, using: 'value_proprietary_net::bigint'
    change_column :stock_trading_days, :value_foreign_buy, :bigint, using: 'value_foreign_buy::bigint'
    change_column :stock_trading_days, :value_foreign_sell, :bigint, using: 'value_foreign_sell::bigint'
    change_column :stock_trading_days, :value_proprietary_buy, :bigint, using: 'value_proprietary_buy::bigint'
    change_column :stock_trading_days, :value_proprietary_sell, :bigint, using: 'value_proprietary_sell::bigint'
  end

  def down
    # Revert price columns to decimal
    change_column :stock_trading_days, :price_close, :decimal, precision: 10, scale: 2
    change_column :stock_trading_days, :price_change, :decimal, precision: 10, scale: 2
    change_column :stock_trading_days, :price_open, :decimal, precision: 10, scale: 2
    change_column :stock_trading_days, :price_high, :decimal, precision: 10, scale: 2
    change_column :stock_trading_days, :price_low, :decimal, precision: 10, scale: 2
    change_column :stock_trading_days, :price_average, :decimal, precision: 10, scale: 2

    # Revert volume columns to bigint
    change_column :stock_trading_days, :volume_total, :bigint
    change_column :stock_trading_days, :volume_match, :bigint
    change_column :stock_trading_days, :volume_negotiated, :bigint
    change_column :stock_trading_days, :volume_foreign_net, :bigint
    change_column :stock_trading_days, :volume_foreign_buy, :bigint
    change_column :stock_trading_days, :volume_foreign_sell, :bigint
    change_column :stock_trading_days, :volume_proprietary_net, :bigint
    change_column :stock_trading_days, :volume_proprietary_buy, :bigint
    change_column :stock_trading_days, :volume_proprietary_sell, :bigint

    # Revert value columns to decimal
    change_column :stock_trading_days, :value_total, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_match, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_negotiated, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_foreign_net, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_proprietary_net, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_foreign_buy, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_foreign_sell, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_proprietary_buy, :decimal, precision: 20, scale: 2
    change_column :stock_trading_days, :value_proprietary_sell, :decimal, precision: 20, scale: 2
  end
end
