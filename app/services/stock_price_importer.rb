require "net/http"
require "json"

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
    @today = Date.today.strftime("%d/%m/%Y")
  end

  def import
    # Fetch SSI price data with retry
    # Format date as DD/MM/YYYY for SSI API
    ssi_to_date = Date.today.strftime("%d/%m/%Y")
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
    ssi_data = ssi_json["data"] || []

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
    cafef_data = cafef_json.dig("Data", "Data", "ListDataTudoanh") || []

    # Index CafeF by date for merging
    cafef_by_date = {}
    cafef_data.each do |item|
      date = Date.strptime(item["Date"], "%d/%m/%Y") rescue nil
      next unless date
      cafef_by_date[date] = item
    end

    ssi_data.each do |item|
      date = Date.strptime(item["tradingDate"][0, 10], "%d/%m/%Y") rescue nil
      next unless date && @ticker.id
      cafef_item = cafef_by_date[date] || {}
      trading_day = StockTradingDay.find_by(ticker_id: @ticker.id, trading_date: date)
      next if trading_day # Skip if already exists
      trading_day = StockTradingDay.new(ticker_id: @ticker.id, trading_date: date)
      trading_day.assign_attributes(
        price_close: item["closePrice"],
        price_change: item["priceChange"],
        price_change_pct: item["perPriceChange"],
        price_average: item["averagePrice"],
        price_open: item["openPrice"],
        price_high: item["highestPrice"],
        price_low: item["lowestPrice"],
        volume_match: item["totalMatchVol"],
        volume_negotiated: item["totalDealVol"],
        volume_total: item["totalMatchVol"] + item["totalDealVol"],
        volume_foreign_buy: item["foreignBuyVolTotal"],
        volume_foreign_sell: item["foreignSellVolTotal"],
        volume_foreign_net: item["netBuySellVol"].to_i,
        volume_proprietary_buy: cafef_item["KLcpMua"] || 0,
        volume_proprietary_sell: cafef_item["KlcpBan"] || 0,
        volume_proprietary_net: (cafef_item["KLcpMua"] || 0).to_i - (cafef_item["KlcpBan"] || 0).to_i,
        value_match: item["totalMatchVal"],
        value_negotiated: item["totalDealVal"],
        value_total: item["totalMatchVal"] + item["totalDealVal"],
        value_foreign_net: item["netBuySellVal"],
        value_foreign_buy: item["foreignBuyValTotal"],
        value_foreign_sell: item["foreignSellValTotal"],
        value_proprietary_buy: cafef_item["GtMua"] || 0,
        value_proprietary_sell: cafef_item["GtBan"] || 0,
        value_proprietary_net: (cafef_item["GtMua"] || 0).to_i - (cafef_item["GtBan"] || 0).to_i,
        share_listed: item["listedShares"],
        share_foreign_max_allowed: item["foreignMaxRoom"],
        share_foreign_add_allowed: item["foreignAddRoom"],
        share_foreign_own_rate: item["foreignOwnRate"],
        # Add more fields as needed from item/cafef_item
        created_at: date
      )
      begin
        trading_day.save!
        Rails.logger.info "#{trading_day.inspect}"
      rescue => e
        Rails.logger.error "Failed to save stock_trading_day for #{@symbol} #{date}: #{e.message}"
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
