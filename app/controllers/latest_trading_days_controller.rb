class LatestTradingDaysController < ApplicationController
  def index
    latest_date = StockTradingDay.maximum(:trading_date)
    trading_days = StockTradingDay.includes(ticker: :group).where(trading_date: latest_date)
    grouped = trading_days.group_by { |td| td.ticker.group.name }
    @group_trading_days = {}
    grouped.each do |group_name, tds|
      @group_trading_days[group_name] = tds.map { |td| { ticker: td.ticker, trading_day: td } }
    end
  end
end
