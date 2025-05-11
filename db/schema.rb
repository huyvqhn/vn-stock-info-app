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

ActiveRecord::Schema[8.0].define(version: 2025_05_10_145047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_records", force: :cascade do |t|
    t.string "hashkey"
    t.integer "ticker_id", null: false
    t.date "date"
    t.decimal "price"
    t.decimal "change_percent"
    t.decimal "vol_td"
    t.decimal "khop_td"
    t.decimal "vol_nn"
    t.decimal "khop_nn"
    t.decimal "so_huu_nn"
    t.decimal "rate_nn"
    t.decimal "rate_td"
    t.decimal "day_vol"
    t.decimal "day_trade"
    t.decimal "max_percent_nn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticker_id"], name: "index_stock_records_on_ticker_id"
  end

  create_table "tickers", force: :cascade do |t|
    t.string "symbol", null: false
    t.integer "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_tickers_on_group_id"
  end

  add_foreign_key "stock_records", "tickers"
  add_foreign_key "tickers", "groups"
end
