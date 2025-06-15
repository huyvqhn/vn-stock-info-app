# frozen_string_literal: true

require "net/http"
require "json"

class StockTradingDayImporter
  # Removed import_for_symbol method as it's no longer needed

  def self.fetch_json(endpoint)
    url = URI(endpoint)
    response = Net::HTTP.get(url)
    json = JSON.parse(response)
    json
  rescue
    []
  end

  def self.consolidate_proprietary_data(data)
    return {} unless data.is_a?(Array)
    data.group_by { |item| item["Symbol"] || item["symbol"] }.transform_values do |items|
      {
        "MatchVol" => items.sum { |i| i["MatchVol"].to_i },
        "MatchVal" => items.sum { |i| i["MatchVol"].to_i * i["Price"].to_f }
      }
    end
  end

  def self.import_all
    bvsc_data = fetch_json(MarketApiEndpoints::TOTAL_NN_BVSC)["d"]
    proprietary_vps_data = fetch_json(MarketApiEndpoints::PROPRIETARY_VPS)["data"]
    negotiated_hnx_bvsc_data = fetch_json(MarketApiEndpoints::NEGOTIATE_HNX_BVSC)["d"]
    negotiated_hose_bvsc_data = fetch_json(MarketApiEndpoints::NEGOTIATE_HOSE_BVSC)["d"]
    negotiated_upcom_bvsc_data = fetch_json(MarketApiEndpoints::NEGOTIATE_UPCOM_BVSC)["d"]

    trade_info_by_symbol = index_by_symbol(bvsc_data)
    proprietary_by_symbol = index_by_symbol(proprietary_vps_data)
    negotiated_hnx_by_symbol = consolidate_proprietary_data(negotiated_hnx_bvsc_data)
    negotiated_hose_by_symbol = consolidate_proprietary_data(negotiated_hose_bvsc_data)
    negotiated_upcom_by_symbol = consolidate_proprietary_data(negotiated_upcom_bvsc_data)

    # Merge negotiated data from all sources by symbol
    all_negotiated_by_symbol = negotiated_hnx_by_symbol.dup
    [ negotiated_hose_by_symbol, negotiated_upcom_by_symbol ].each do |src|
      src.each do |symbol, values|
        all_negotiated_by_symbol[symbol] ||= { "MatchVol"=>0, "MatchVal"=>0 }
        all_negotiated_by_symbol[symbol]["MatchVol"] += values["MatchVol"]
        all_negotiated_by_symbol[symbol]["MatchVal"] += values["MatchVal"]
      end
    end

    puts "hello"

    Ticker.find_each do |ticker|
      begin
        symbol = ticker.symbol
        trade_info = trade_info_by_symbol[symbol] || {}
        trade_proprietary = proprietary_by_symbol[symbol] || {}
        trade_negotiated = all_negotiated_by_symbol[symbol] || {}

        # Ensure all related data is for the same trading date as trade_info
        anchor_date = trade_info["tradingdate"]
        proprietary = nil
        if all_proprietary_by_symbol[symbol].is_a?(Hash)
          prop = all_proprietary_by_symbol[symbol]
          if prop["tradingDate"].to_s == anchor_date.to_s
            proprietary = prop
          end
        end
        vps_self = nil
        if vps_by_symbol[symbol].is_a?(Hash)
          vps = vps_by_symbol[symbol]
          if vps["tradingDate"].to_s == anchor_date.to_s
            vps_self = vps
          end
        end

        # Aggregate negotiated volumes/values from all proprietary endpoints
        volume_match = trade_info["totalTrading"].to_i
        value_match = trade_info["totalTradingValue"].to_f
        volume_negotiated = trade_negotiated["MatchVol"].to_i
        value_negotiated = trade_negotiated["MatchVal"].to_f
        volume_total = volume_match + volume_negotiated
        value_total = value_match + value_negotiated

        volume_foreign_buy = trade_info["foreignBuy"].to_i
        volume_foreign_sell = trade_info["foreignSell"].to_i
        volume_foreign_net = volume_foreign_buy - volume_foreign_sell

        volume_proprietary_buy = trade_proprietary["TMatchBuyVol"].to_i
        volume_proprietary_sell = trade_proprietary["TMatchSellVol"].to_i

        value_proprietary_buy = trade_proprietary["TMatchBuyVal"].to_f
        value_proprietary_sell = trade_proprietary["TMatchSellVal"].to_f

        value_foreign_buy = volume_foreign_buy * trade_info["averagePrice"].to_f
        value_foreign_sell = volume_foreign_sell * trade_info["averagePrice"].to_f
        value_foreign_net = value_foreign_buy - value_foreign_sell

        share_listed = trade_info["ListedShare"].to_i
        share_foreign_max_allowed = trade_info["foreignRoom"].to_i
        share_foreign_add_allowed = trade_info["foreignRemain"].to_i
        share_foreign_own_rate = (trade_info["foreignRoom"].to_f > 0) ? (100.0 - (trade_info["foreignRemain"].to_f / trade_info["foreignRoom"].to_f * 100.0)) : nil

        price_average = trade_info["averagePrice"].to_f
        price_open = trade_info["open"].to_f
        price_high = trade_info["high"].to_f
        price_low = trade_info["low"].to_f
        price_close = trade_info["closePrice"].to_f
        price_change = trade_info["change"].to_f
        price_change_pct = trade_info["changePercent"].to_f

        attrs = {
          ticker_id: ticker.id,
          trading_date: trade_info["tradingdate"] ? Date.parse(trade_info["tradingdate"]) : nil, # Use tradingdate from trade_info
          volume_match: volume_match,
          volume_negotiated: volume_negotiated,
          volume_total: volume_total,
          volume_foreign_buy: volume_foreign_buy,
          volume_foreign_sell: volume_foreign_sell,
          volume_foreign_net: volume_foreign_net,
          volume_proprietary_buy: volume_proprietary_buy,
          volume_proprietary_sell: volume_proprietary_sell,
          # volume_proprietary_net: volume_negotiated_net,

          value_match: value_match,
          value_negotiated: value_negotiated,
          value_total: value_total,
          value_proprietary_buy: value_proprietary_buy,
          value_proprietary_sell: value_proprietary_sell,
          # value_proprietary_net: value_negotiated_net,
          value_foreign_buy: value_foreign_buy,
          value_foreign_sell: value_foreign_sell,
          value_foreign_net: value_foreign_net,

          share_listed: share_listed,
          share_foreign_max_allowed: share_foreign_max_allowed,
          share_foreign_add_allowed: share_foreign_add_allowed,
          share_foreign_own_rate: share_foreign_own_rate,

          price_average: price_average,
          price_open: price_open,
          price_high: price_high,
          price_low: price_low,
          price_close: price_close,
          price_change: price_change,
          price_change_pct: price_change_pct,
          created_at: Time.now,
          updated_at: Time.now
        }
        # Assign market depth attributes: set to nil if value is nil or 0, else assign the value
        attrs[:market_depth_bid_price_1] = (trade_info["bidPrice1"].to_f == 0 ? nil : trade_info["bidPrice1"].to_f) unless trade_info["bidPrice1"].nil?
        attrs[:market_depth_bid_price_2] = (trade_info["bidPrice2"].to_f == 0 ? nil : trade_info["bidPrice2"].to_f) unless trade_info["bidPrice2"].nil?
        attrs[:market_depth_bid_price_3] = (trade_info["bidPrice3"].to_f == 0 ? nil : trade_info["bidPrice3"].to_f) unless trade_info["bidPrice3"].nil?
        attrs[:market_depth_bid_volume_1] = (trade_info["bidVol1"].to_i == 0 ? nil : trade_info["bidVol1"].to_i) unless trade_info["bidVol1"].nil?
        attrs[:market_depth_bid_volume_2] = (trade_info["bidVol2"].to_i == 0 ? nil : trade_info["bidVol2"].to_i) unless trade_info["bidVol2"].nil?
        attrs[:market_depth_bid_volume_3] = (trade_info["bidVol3"].to_i == 0 ? nil : trade_info["bidVol3"].to_i) unless trade_info["bidVol3"].nil?
        attrs[:market_depth_ask_price_1] = (trade_info["offerPrice1"].to_f == 0 ? nil : trade_info["offerPrice1"].to_f) unless trade_info["offerPrice1"].nil?
        attrs[:market_depth_ask_price_2] = (trade_info["offerPrice2"].to_f == 0 ? nil : trade_info["offerPrice2"].to_f) unless trade_info["offerPrice2"].nil?
        attrs[:market_depth_ask_price_3] = (trade_info["offerPrice3"].to_f == 0 ? nil : trade_info["offerPrice3"].to_f) unless trade_info["offerPrice3"].nil?
        attrs[:market_depth_ask_volume_1] = (trade_info["offerVol1"].to_i == 0 ? nil : trade_info["offerVol1"].to_i) unless trade_info["offerVol1"].nil?
        attrs[:market_depth_ask_volume_2] = (trade_info["offerVol2"].to_i == 0 ? nil : trade_info["offerVol2"].to_i) unless trade_info["offerVol2"].nil?
        attrs[:market_depth_ask_volume_3] = (trade_info["offerVol3"].to_i == 0 ? nil : trade_info["offerVol3"].to_i) unless trade_info["offerVol3"].nil?
        Rails.logger.info attrs
        existing = StockTradingDay.find_by(ticker_id: ticker.id, trading_date: attrs[:trading_date])
        if existing
          existing.update(attrs)
          Rails.logger.info "Updated StockTradingDay for #{ticker.symbol} on #{attrs[:trading_date]}"
        else
          StockTradingDay.create!(attrs)
          Rails.logger.info "Created StockTradingDay for #{ticker.symbol} on #{attrs[:trading_date]}"
        end
      rescue => e
        Rails.logger.error "Failed to import trading day for \\#{ticker.symbol}: \\#{e.message}"
      end
    end
  end

  def self.index_by_symbol(data)
    return {} unless data.is_a?(Array)
    data.index_by { |item| item["symbol"] || item["Symbol"] }
  end
end
