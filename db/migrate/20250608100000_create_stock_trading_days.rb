class CreateStockTradingDays < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_trading_days do |t|
      # Core References
      t.references :ticker, null: false, foreign_key: true, index: true
      t.date :trading_date, null: false

      # OHLCV Data
      t.decimal :price_close, precision: 10, scale: 2, null: false
      t.decimal :price_change, precision: 10, scale: 2
      t.decimal :price_change_pct, precision: 6, scale: 2
      t.decimal :price_average, precision: 10, scale: 2
      t.decimal :price_open, precision: 10, scale: 2, null: false
      t.decimal :price_high, precision: 10, scale: 2, null: false
      t.decimal :price_low, precision: 10, scale: 2, null: false

      # Trading Volume
      t.bigint :volume_total
      t.bigint :volume_match
      t.bigint :volume_negotiated

      # Foreign Trading
      t.bigint :volume_foreign_net
      t.bigint :volume_foreign_buy
      t.bigint :volume_foreign_sell

      # Proprietary Trading
      t.bigint :volume_proprietary_net
      t.bigint :volume_proprietary_buy
      t.bigint :volume_proprietary_sell

      # Trading Value (in VND)
      t.decimal :value_total, precision: 20, scale: 2
      t.decimal :value_match, precision: 20, scale: 2
      t.decimal :value_negotiated, precision: 20, scale: 2
      t.decimal :value_foreign_net, precision: 20, scale: 2
      t.decimal :value_proprietary_net, precision: 20, scale: 2
      t.decimal :value_foreign_buy, precision: 20, scale: 2
      t.decimal :value_foreign_sell, precision: 20, scale: 2
      t.decimal :value_proprietary_buy, precision: 20, scale: 2
      t.decimal :value_proprietary_sell, precision: 20, scale: 2

      # Share Statistics
      t.bigint :share_listed
      t.bigint :share_foreign_max_allowed
      t.bigint :share_foreign_add_allowed
      t.decimal :share_foreign_own_rate, precision: 6, scale: 2

      # Technical Indicators
      t.decimal :indicator_ma_20, precision: 10, scale: 2
      t.decimal :indicator_ma_50, precision: 10, scale: 2
      t.decimal :indicator_ma_200, precision: 10, scale: 2
      t.decimal :indicator_rsi_14, precision: 6, scale: 2
      t.decimal :indicator_macd, precision: 6, scale: 2
      t.decimal :indicator_macd_signal, precision: 6, scale: 2
      t.decimal :indicator_macd_histogram, precision: 6, scale: 2
      t.decimal :indicator_volume_ma_20, precision: 15, scale: 2

      # Market Depth (Level 1-3)
      t.decimal :market_depth_bid_price_1, precision: 10, scale: 2
      t.decimal :market_depth_bid_price_2, precision: 10, scale: 2
      t.decimal :market_depth_bid_price_3, precision: 10, scale: 2
      t.bigint :market_depth_bid_volume_1
      t.bigint :market_depth_bid_volume_2
      t.bigint :market_depth_bid_volume_3

      t.decimal :market_depth_ask_price_1, precision: 10, scale: 2
      t.decimal :market_depth_ask_price_2, precision: 10, scale: 2
      t.decimal :market_depth_ask_price_3, precision: 10, scale: 2
      t.bigint :market_depth_ask_volume_1
      t.bigint :market_depth_ask_volume_2
      t.bigint :market_depth_ask_volume_3

      t.timestamps

      # Unique compound index
      t.index [ :ticker_id, :trading_date ], unique: true, name: 'idx_trading_days_ticker_date'

      # Additional indexes for common queries
      t.index :trading_date
      t.index [ :ticker_id, :price_close ]
      t.index [ :ticker_id, :volume_total ]
    end

    execute <<-SQL
      ALTER TABLE stock_trading_days
      ADD CONSTRAINT check_volumes
      CHECK (
        COALESCE(volume_total, 0) >= 0 AND
        COALESCE(volume_match, 0) >= 0 AND
        COALESCE(volume_negotiated, 0) >= 0
      );
    SQL

    execute <<-SQL
      ALTER TABLE stock_trading_days
      ADD CONSTRAINT check_market_depth
      CHECK (
        (market_depth_ask_price_1 IS NULL OR market_depth_bid_price_1 IS NULL OR market_depth_ask_price_1 >= market_depth_bid_price_1) AND
        (market_depth_ask_price_1 IS NULL OR market_depth_ask_price_2 IS NULL OR market_depth_ask_price_1 <= market_depth_ask_price_2) AND
        (market_depth_ask_price_2 IS NULL OR market_depth_ask_price_3 IS NULL OR market_depth_ask_price_2 <= market_depth_ask_price_3) AND
        (market_depth_bid_price_1 IS NULL OR market_depth_bid_price_2 IS NULL OR market_depth_bid_price_1 >= market_depth_bid_price_2) AND
        (market_depth_bid_price_2 IS NULL OR market_depth_bid_price_3 IS NULL OR market_depth_bid_price_2 >= market_depth_bid_price_3)
      );
    SQL
  end

  def down
    drop_table :stock_trading_days
  end
end
