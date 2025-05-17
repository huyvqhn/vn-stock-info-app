class MarketGroupsController < ApplicationController
  def index
    all_ticker = Ticker.pluck(:symbol).join(',')
    ticker_hash = Ticker.joins(:group).pluck(:symbol, 'groups.name').to_h
    apiUrl = "https://online.bvsc.com.vn/datafeed/instruments?symbols=#{all_ticker}"

    tickers_results = api_data(apiUrl)

    @group_results = ticker_hash.group_by { |symbol, group_name| group_name }
                               .transform_values do |arr|
      arr.map { |(symbol, _)| tickers_results.find { |t| t['symbol'] == symbol } }.compact
    end



    # Rails.logger.info(tickers_results)

    # service = MarketDataService.new


  end

  def api_data(api_url)
    url = URI(api_url)
    response = Net::HTTP.get(url)
    parsed = JSON.parse(response)


    # @api_result = { 'd' => parsed['d']}
    parsed['d']
    # return @api_result
    # Rails.logger.info @api_result
  end

  # def make_group()
end
