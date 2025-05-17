class MarketGroupsController < ApplicationController
  def index
    all_ticker = Ticker.pluck(:symbol).join(',')


    # ticker_hash = Ticker.joins(:group).pluck(:symbol, 'groups.name').to_h
    ticker_arr = Ticker.joins(:group).pluck(:symbol, 'groups.name')
    group_hash = ticker_arr.group_by { |symbol, group_name| group_name }.transform_values{|arr| arr.map {|(symbol,_)| symbol}}


    tickers_results = MarketDataService.fetch_tickers(all_ticker)

    presenter = MarketGroupPresenter.new
    # @group_results = presenter.group_results
    @group_results = presenter.group_results(group_hash, tickers_results)

    # Rails.logger.info(tickers_results)
  end
end
