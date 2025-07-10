# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_29_101000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_prices", force: :cascade do |t|
    t.bigint "ticker_id", null: false
    t.decimal "price", precision: 15, scale: 2, null: false
    t.bigint "volume_total", null: false
    t.decimal "percent_change", precision: 6, scale: 2
    t.bigint "volume_foreign_matching"
    t.bigint "volume_self_matching"
    t.date "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "average_price", precision: 15, scale: 2
    t.decimal "total_trading_value", precision: 20, scale: 2
    t.bigint "foreign_room"
    t.bigint "foreign_remain"
    t.decimal "change", precision: 15, scale: 2
    t.bigint "volume_matching"
    t.bigint "volume_deal"
    t.decimal "open", precision: 15, scale: 2
    t.decimal "high", precision: 15, scale: 2
    t.decimal "low", precision: 15, scale: 2
    t.decimal "value_self_net", precision: 20, scale: 2
    t.decimal "value_foreign_net", precision: 20, scale: 2
    t.decimal "value_total_net", precision: 20, scale: 2
    t.index ["ticker_id", "recorded_at"], name: "index_stock_prices_on_ticker_id_and_recorded_at", unique: true
    t.index ["ticker_id"], name: "index_stock_prices_on_ticker_id"
  end

  create_table "stock_trading_days", force: :cascade do |t|
    t.bigint "ticker_id", null: false
    t.date "trading_date", null: false
    t.integer "price_close", null: false
    t.integer "price_change"
    t.decimal "price_change_pct", precision: 6, scale: 2
    t.integer "price_average"
    t.integer "price_open", null: false
    t.integer "price_high", null: false
    t.integer "price_low", null: false
    t.integer "volume_total"
    t.integer "volume_match"
    t.integer "volume_negotiated"
    t.integer "volume_foreign_buy"
    t.integer "volume_foreign_sell"
    t.integer "volume_foreign_net"
    t.integer "volume_proprietary_buy"
    t.integer "volume_proprietary_sell"
    t.integer "volume_proprietary_net"
    t.bigint "value_total"
    t.bigint "value_match"
    t.bigint "value_negotiated"
    t.bigint "value_foreign_net"
    t.bigint "value_proprietary_net"
    t.bigint "value_foreign_buy"
    t.bigint "value_foreign_sell"
    t.bigint "value_proprietary_buy"
    t.bigint "value_proprietary_sell"
    t.bigint "share_listed"
    t.bigint "share_foreign_max_allowed"
    t.bigint "share_foreign_add_allowed"
    t.decimal "share_foreign_own_rate", precision: 6, scale: 2
    t.decimal "indicator_ma_20", precision: 10, scale: 2
    t.decimal "indicator_ma_50", precision: 10, scale: 2
    t.decimal "indicator_ma_200", precision: 10, scale: 2
    t.decimal "indicator_rsi_14", precision: 6, scale: 2
    t.decimal "indicator_macd", precision: 6, scale: 2
    t.decimal "indicator_macd_signal", precision: 6, scale: 2
    t.decimal "indicator_macd_histogram", precision: 6, scale: 2
    t.decimal "indicator_volume_ma_20", precision: 15, scale: 2
    t.decimal "market_depth_bid_price_1", precision: 10, scale: 2
    t.decimal "market_depth_bid_price_2", precision: 10, scale: 2
    t.decimal "market_depth_bid_price_3", precision: 10, scale: 2
    t.bigint "market_depth_bid_volume_1"
    t.bigint "market_depth_bid_volume_2"
    t.bigint "market_depth_bid_volume_3"
    t.decimal "market_depth_ask_price_1", precision: 10, scale: 2
    t.decimal "market_depth_ask_price_2", precision: 10, scale: 2
    t.decimal "market_depth_ask_price_3", precision: 10, scale: 2
    t.bigint "market_depth_ask_volume_1"
    t.bigint "market_depth_ask_volume_2"
    t.bigint "market_depth_ask_volume_3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "indicator_pivot_foreign", default: false
    t.boolean "indicator_pivot_proprietary", default: false
    t.boolean "indicator_volume_spike", default: false
    t.boolean "indicator_candle_reversal", default: false
    t.float "volume_change_pct"
    t.index ["ticker_id", "price_close"], name: "index_stock_trading_days_on_ticker_id_and_price_close"
    t.index ["ticker_id", "trading_date"], name: "idx_trading_days_ticker_date", unique: true
    t.index ["ticker_id", "volume_total"], name: "index_stock_trading_days_on_ticker_id_and_volume_total"
    t.index ["ticker_id"], name: "index_stock_trading_days_on_ticker_id"
    t.index ["trading_date"], name: "index_stock_trading_days_on_trading_date"
    t.check_constraint "(market_depth_ask_price_1 IS NULL OR market_depth_bid_price_1 IS NULL OR market_depth_ask_price_1 >= market_depth_bid_price_1) AND (market_depth_ask_price_1 IS NULL OR market_depth_ask_price_2 IS NULL OR market_depth_ask_price_1 <= market_depth_ask_price_2) AND (market_depth_ask_price_2 IS NULL OR market_depth_ask_price_3 IS NULL OR market_depth_ask_price_2 <= market_depth_ask_price_3) AND (market_depth_bid_price_1 IS NULL OR market_depth_bid_price_2 IS NULL OR market_depth_bid_price_1 >= market_depth_bid_price_2) AND (market_depth_bid_price_2 IS NULL OR market_depth_bid_price_3 IS NULL OR market_depth_bid_price_2 >= market_depth_bid_price_3)", name: "check_market_depth"
    t.check_constraint "COALESCE(volume_total::bigint, 0::bigint) >= 0 AND COALESCE(volume_match::bigint, 0::bigint) >= 0 AND COALESCE(volume_negotiated::bigint, 0::bigint) >= 0", name: "check_volumes"
  end

  create_table "tickers", force: :cascade do |t|
    t.string "symbol", null: false
    t.integer "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "exchange"
    t.string "sector"
    t.string "industry"
    t.boolean "is_active", default: true
    t.string "description"
    t.decimal "beta", precision: 8, scale: 4
    t.decimal "dividend_yield_ttm", precision: 8, scale: 4
    t.index ["group_id"], name: "index_tickers_on_group_id"
  end

  add_foreign_key "stock_prices", "tickers"
  add_foreign_key "stock_trading_days", "tickers"
  add_foreign_key "tickers", "groups"
end
