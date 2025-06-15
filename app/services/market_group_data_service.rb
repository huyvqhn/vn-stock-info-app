class MarketGroupDataService
  def self.fetch_grouped_market_data
    all_ticker = Ticker.pluck(:symbol).join(",")
    ticker_arr = Ticker.joins(:group).pluck(:symbol, "groups.name")
    group_hash = ticker_arr.group_by { |symbol, group_name| group_name }.transform_values { |arr| arr.map { |(symbol, _)| symbol } }
    tickers_results = MarketDataService.fetch_tickers(all_ticker)
    presenter = MarketGroupPresenter.new
    presenter.group_results(group_hash, tickers_results)
  end
end
