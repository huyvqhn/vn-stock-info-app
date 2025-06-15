require 'net/http'
require 'json'

class ApiTestService
  # API_URL = 'https://fwtapi2.fialda.com/api/services/app/StockInfo/GetSelfTrading?symbol=VHM&toDate=2025-05-24&pageNumber=1&pageSize=1'
  # API_URL = 'https://iboard-api.ssi.com.vn/statistics/company/stock-price?symbol=VHM&page=1&pageSize=10&toDate=24/05/2025'
  API_URL = 'https://histdatafeed.vps.com.vn/proprietary/snapshot/TOTAL'
  # API_URL = 'https://cafef.vn/du-lieu/Ajax/PageNew/DataHistory/GDKhoiNgoai.ashx?Symbol=ACB&StartDate=&EndDate=&PageIndex=1&PageSize=20'

  def self.test
    url = URI(API_URL)
    begin
      response = Net::HTTP.get(url)
      puts "Raw response: #{response}"
      json = JSON.parse(response)
      puts "Parsed JSON: #{json.inspect}"
      true
    rescue => e
      puts "API fetch error: #{e.message}"
      false
    end
  end
end
