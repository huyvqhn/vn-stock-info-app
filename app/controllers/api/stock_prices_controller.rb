class Api::StockPricesController < ApplicationController
  protect_from_forgery with: :null_session

  # POST /api/stock_prices/import_all?limit=5
  def import_all
    limit = params[:limit]&.to_i
    begin
      # StockPriceImporter.import_all(limit: limit)
      StockPriceImporter.import_all
      render json: { status: "ok", message: "Import started 'all'} tickers" }
    rescue => e
      render json: { status: "error", message: e.message, backtrace: e.backtrace }, status: 500
    end
  end

  # POST /api/stock_prices/import_all_from_groups
  def import_all_from_groups
    group_results = params[:group_results_json].present? ? JSON.parse(params[:group_results_json]) : {}
    count = 0
    group_results.each do |_group, stocks|
      stocks.each do |stock|
        next unless stock["symbol"] && stock["close_price"]
        ticker = Ticker.find_by(symbol: stock["symbol"])
        next unless ticker
        # Use today's date if not present in stock
        date = stock["date"].present? ? Date.parse(stock["date"]) : Date.today rescue Date.today
        stock_price = StockPrice.find_or_initialize_by(ticker_id: ticker.id, recorded_at: date)
        stock_price.assign_attributes(
          price: stock["close_price"],
          percent_change: stock["change_percent"],
          volume_total: stock["all_vol"],
          volume_matching: stock["all_matching"],
          volume_foreign_matching: stock["net_vol_nn"],
          value_foreign_net: stock["net_gd_nn"],
          # Add more mappings as needed
        )
        count += 1 if stock_price.save
      end
    end
    flash[:notice] = "Imported #{count} stock prices from group results"
    redirect_to market_groups_path
  rescue => e
    flash[:alert] = "Error: #{e.message}"
    redirect_to market_groups_path
  end
end
