class MigrateDataToStockTradingDays < ActiveRecord::Migration[7.0]
  def up
    # First, let's create a mapping query that converts old data to new format
    execute <<-SQL
      INSERT INTO stock_trading_days (
        ticker_id,
        trading_date,
        price_close,
        price_change,
        price_change_pct,
        price_average,
        price_open,
        price_high,
        price_low,
        volume_total,
        volume_match,
        volume_negotiated,
        value_total,
        value_match,
        value_negotiated,
        volume_foreign_net,
        value_foreign_net,
        created_at,
        updated_at
      )
      SELECT#{' '}
        ticker_id,
        recorded_at,
        price,
        change,
        percent_change,
        average_price,
        "open",
        high,
        low,
        COALESCE(volume_matching, 0) + COALESCE(volume_deal, 0) as volume_total,
        volume_matching as volume_match,
        volume_deal as volume_negotiated,
        value_total_net + (COALESCE(volume_deal, 0) * COALESCE(average_price, 0)) as value_total,
        value_total_net as value_match,#{'        '}
        COALESCE(volume_deal, 0) * COALESCE(average_price, 0) as value_negotiated,
        volume_foreign_matching as volume_foreign_net,
        value_foreign_net,
        created_at,
        updated_at
      FROM stock_prices
      WHERE ticker_id IS NOT NULL
      AND recorded_at IS NOT NULL
      AND price IS NOT NULL
      AND volume_total > 0;
    SQL

    # Update foreign ownership data where available
    execute <<-SQL
      UPDATE stock_trading_days std
      SET share_foreign_max_allowed = sp.foreign_room
      FROM stock_prices sp
      WHERE std.ticker_id = sp.ticker_id#{' '}
      AND std.trading_date = sp.recorded_at
      AND sp.foreign_room IS NOT NULL;
    SQL

    # Log the migration results
    total_source = execute("SELECT COUNT(*) FROM stock_prices;").first['count']
    total_migrated = execute("SELECT COUNT(*) FROM stock_trading_days;").first['count']

    puts "Migration Summary:"
    puts "Total records in stock_prices: #{total_source}"
    puts "Total records migrated to stock_trading_days: #{total_migrated}"
  end

  def down
    execute "TRUNCATE stock_trading_days CASCADE;"
  end
end
