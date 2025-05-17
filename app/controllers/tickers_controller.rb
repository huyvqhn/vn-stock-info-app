require 'net/http'
require 'json'
class TickersController < ApplicationController
  def index
    @tickers = Ticker.all
    api_data
  end

  def api_data
    url = URI('https://iboard-api.ssi.com.vn/statistics/company/stock-price?symbol=VHM&page=1&fromDate=09/05/2025&toDate=10/05/2025')
    response = Net::HTTP.get(url)
    @api_result = JSON.parse(response)
  end
end
