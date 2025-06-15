class MarketDataEndDayJob < ApplicationJob
  queue_as :default

  def perform(*args)
    tickers_by_group = MarketDataService.fetch_tickers_by_group
    Rails.logger.info("MarketDataEndDayJob #{tickers_by_group.to_json}")
  end
end
