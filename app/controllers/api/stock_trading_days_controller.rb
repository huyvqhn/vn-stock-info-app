class Api::StockTradingDaysController < ApplicationController
  skip_before_action :verify_authenticity_token
  # POST /api/stock_trading_days/import_all
  # GET /api/stock_trading_days/import_all
  def import_all
    StockTradingDayImporter.import_all
    render json: { status: "ok", message: "Stock trading days imported successfully" }
  end
end
