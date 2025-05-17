# frozen_string_literal: true

class MarketDataService
  API_URL = 'https://online.bvsc.com.vn/datafeed/instruments?symbols='
  # url = URI('https://iboard-api.ssi.com.vn/statistics/company/stock-price?symbol=VHM&page=1&fromDate=09/05/2025&toDate=10/05/2025')

  def self.fetch_tickers(all_ticker)
    url = URI("#{API_URL}#{all_ticker}")
    # response = Net::HTTP.get(url)
    response = Net::HTTP.get(url)
    JSON.parse(response)['d']
  end
end