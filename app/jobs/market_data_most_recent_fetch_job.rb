class MarketDataMostRecentFetchJob < ApplicationJob
  queue_as :default

  def perform
    # debugger
    all_ticker = Ticker.pluck(:symbol).join(',')
    tickers_results = MarketDataService.fetch_tickers(all_ticker)

    ticker_arr = Ticker.joins(:group).pluck(:symbol, 'groups.name')
    group_hash = ticker_arr.group_by { |symbol, group_name| group_name }.transform_values{ |arr| arr.map { |(symbol,_)| symbol } }

    presenter = MarketGroupPresenter.new
    result = presenter.group_results(group_hash, tickers_results)
    # Rails.logger.info("MarketDataMostRecentFetchJob.vn_stock_result #{result.inspect}")
    Rails.cache.write('MarketDataMostRecentFetchJob.vn_stock_result', result.to_json, expires_in: 1.hour)
    # Rails.cache.write('MarketDataMostRecentFetchJob.test', "result")
    # Rails.cache.write("test", "value")

  end
end
