require 'net/http'
require 'json'

class StockPriceImporter

  def self.import_all
    # debugger
    Ticker.find_each do |ticker|
      # debugger
      new(ticker).import
    end
  end
  # def self.import_all(limit: nil)
  #   tickers = limit ? Ticker.limit(limit) : Ticker.all
  #   tickers.find_each do |ticker|
  #     # next if StockPrice.exists?(ticker_id: ticker.id, recorded_at: today)
  #     new(ticker).import
  #     sleep 1
  #   end
  # end

  def initialize(ticker)
    @ticker = ticker
    @symbol = ticker.symbol
    @today = Date.today.strftime('%d/%m/%Y')
  end

  def import
    # Fetch SSI price data with retry
    # Format date as DD/MM/YYYY for SSI API
    ssi_to_date = Date.today.strftime('%d/%m/%Y')
    ssi_url = "https://iboard-api.ssi.com.vn/statistics/company/stock-price?symbol=#{@symbol}&page=1&toDate=#{ssi_to_date}&pageSize=500"
    ssi_response = nil
    retries = 0
    begin
      ssi_response = Net::HTTP.get(URI(ssi_url))
      ssi_json = JSON.parse(ssi_response)
    rescue => e
      retries += 1
      if retries <= 3
        Rails.logger.warn "vnstock Retrying SSI API for #{@symbol} (attempt \\#{retries}): #{e.message}"
        sleep 2 ** retries
        retry
      else
        Rails.logger.error "vnstock error SSI API for #{ssi_url}   : #{@symbol} did not return JSON: #{ssi_response ? ssi_response[0..100] : e.message}..."
        return
      end
    end
    ssi_data = ssi_json['data'] || []

    # Fetch CafeF proprietary trading data with retry
    cafef_url = "https://cafef.vn/du-lieu/Ajax/PageNew/DataHistory/GDTuDoanh.ashx?Symbol=#{@symbol}&EndDate=#{@today}&PageIndex=1&PageSize=500"
    cafef_response = nil
    retries = 0
    begin
      cafef_response = Net::HTTP.get(URI(cafef_url))
      cafef_json = JSON.parse(cafef_response)
    rescue => e
      retries += 1
      if retries <= 3
        Rails.logger.warn "vnstock Retrying CafeF API for #{@symbol} (attempt \\#{retries}): #{e.message}"
        sleep 2 ** retries
        retry
      else
        Rails.logger.error "vnstock CafeF API for #{cafef_url}  :  #{@symbol} did not return JSON: #{cafef_response ? cafef_response[0..100] : e.message}..."
        return
      end
    end
    cafef_data = cafef_json.dig('Data', 'Data', 'ListDataTudoanh') || []

    # Index CafeF by date for merging
    cafef_by_date = {}
    cafef_data.each do |item|
      date = Date.strptime(item['Date'], '%d/%m/%Y') rescue nil
      next unless date
      cafef_by_date[date] = item
    end

    ssi_data.each do |item|
      date = Date.strptime(item['tradingDate'][0,10], '%d/%m/%Y') rescue nil
      next unless date && @ticker.id
      cafef_item = cafef_by_date[date] || {}
      stock_price = StockPrice.find_by(ticker_id: @ticker.id, recorded_at: date)
      next if stock_price # Skip if already exists
      stock_price = StockPrice.new(ticker_id: @ticker.id, recorded_at: date)
      stock_price.assign_attributes(
        price: item['closePrice'],
        average_price: item['averagePrice'],
        change: item['priceChange'],
        percent_change: item['perPriceChange'],
        volume_total: item['totalMatchVol'],
        volume_deal: item['totalDealVol'],
        volume_matching: item['totalMatchVol'],
        volume_foreign_matching: item['foreignBuyVolTotal'].to_f - item['foreignSellVolTotal'].to_f,
        volume_self_matching: (cafef_item['KLcpMua'] || 0).to_i - (cafef_item['KlcpBan'] || 0).to_i,
        value_self_net: (cafef_item['GtMua'] || 0).to_f - (cafef_item['GtBan'] || 0).to_f,
        value_foreign_net: item['netBuySellVal'],
        value_total_net: item['totalMatchVal'],
        total_trading_value: item['totalMatchVal'],
        foreign_room: item['foreignCurrentRoom'],
        foreign_remain: cafef_item['RoomConLai'],
        open: item['openPrice'],
        high: item['highestPrice'],
        low: item['lowestPrice'],
        recorded_at: date
      )
      begin
        stock_price.save!
      rescue => e
        Rails.logger.error "Failed to save stock_price for #{@symbol} #{date}: #{e.message}"
      end
    end
  end

  private

  def fetch_json(path)
    debugger
    url = URI.join(API_BASE, path)
    response = Net::HTTP.get(url)
    debugger
    JSON.parse(response)
  rescue => e
    Rails.logger.error "API fetch error for #{@symbol}: #{e.message}"
    nil
  end
end
