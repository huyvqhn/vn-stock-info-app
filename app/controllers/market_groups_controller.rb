class MarketGroupsController < ApplicationController

  before_action :set_presenter
  attr_accessor :ticker_arr, :group_hash, :tickers_results
  def index
    # debugger
    prepare_data
    @group_results = @presenter.group_results(group_hash, tickers_results)
    # @group_results = Rails.cache.read('MarketDataMostRecentFetchJob.vn_stock_result') #|| []

    Rails.logger.info("vn_stock_result: #{@group_results.inspect}")
  end

  def top_30
    prepare_data
    @top_30_results = @presenter.top_30_results(tickers_results)

  end

  def prepare_data
    all_ticker = Ticker.pluck(:symbol).join(',')
    self.ticker_arr = Ticker.joins(:group).pluck(:symbol, 'groups.name')
    self.group_hash = ticker_arr.group_by { |symbol, group_name| group_name }.transform_values{ |arr| arr.map { |(symbol,_)| symbol } }
    self.tickers_results = MarketDataService.fetch_tickers(all_ticker)
    # self.tickers_results = Rails.cache.read('tickers_results') || []
  end

  def update_group_tickers
    tickers_by_group = MarketDataService.fetch_tickers_by_group
    Rails.logger.info("MarketDataEndDayJob #{tickers_by_group.to_json}")
  end

  private
  def set_presenter
    @presenter = MarketGroupPresenter.new
  end
end
