class RemoveCheckPricesConstraint < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE stock_trading_days DROP CONSTRAINT IF EXISTS check_prices;
    SQL
  end

  def down
    # Optionally, re-add the constraint here if needed
    # execute <<-SQL
    #   ALTER TABLE stock_trading_days ADD CONSTRAINT check_prices CHECK (
    #     price_high >= COALESCE(price_low, 0) AND
    #     price_high >= COALESCE(price_open, 0) AND
    #     price_high >= COALESCE(price_close, 0) AND
    #     price_low <= COALESCE(price_open, price_high) AND
    #     price_low <= COALESCE(price_close, price_high)
    #   );
    # SQL
  end
end
