class LatestTradingDaysController < ApplicationController
  def index
    @group_trading_days = MarketGroupPresenter.group_trading_days
  end

  def all
    # First get the most recent trading date
    most_recent_date = StockTradingDay.maximum(:trading_date)

    # Then get all records for that date
    @trading_records = StockTradingDay.where(trading_date: most_recent_date)
                                    .includes(ticker: :group)
                                    .order("tickers.symbol")
                                    .map do |trading_day|
      {
        ticker: trading_day.ticker,
        trading_day: trading_day
      }
    end
  end
end
