class LatestTradingDaysController < ApplicationController
  def index
    @group_trading_days = MarketGroupPresenter.group_trading_days
  end

  def all
    # First get the most recent trading date
    most_recent_date = StockTradingDay.maximum(:trading_date)

    # Then get all records for that date
    @all_records = StockTradingDay.where(trading_date: most_recent_date)
                                   .includes(ticker: :group)
                                   .order("tickers.symbol")
                                   .map do |trading_day|
      # Assign market depth fields to ticker for tooltip rendering
      (1..3).each do |i|
        trading_day.ticker.define_singleton_method("market_depth_bid_price_#{i}") { trading_day.send("market_depth_bid_price_#{i}") }
        trading_day.ticker.define_singleton_method("market_depth_bid_volume_#{i}") { trading_day.send("market_depth_bid_volume_#{i}") }
        trading_day.ticker.define_singleton_method("market_depth_ask_price_#{i}") { trading_day.send("market_depth_ask_price_#{i}") }
        trading_day.ticker.define_singleton_method("market_depth_ask_volume_#{i}") { trading_day.send("market_depth_ask_volume_#{i}") }
      end
      {
        ticker: trading_day.ticker,
        aggregate: {
          last_price_close: trading_day.price_close,
          last_share_listed: trading_day.share_listed,
          last_share_foreign_own_rate: trading_day.share_foreign_own_rate,
          sum_price_change: trading_day.price_change,
          sum_price_change_pct: trading_day.price_change_pct,
          sum_volume_total: trading_day.volume_total,
          sum_volume_negotiated: trading_day.volume_negotiated,
          sum_value_total: trading_day.value_total,
          sum_value_negotiated: trading_day.value_negotiated,
          sum_value_foreign_buy: trading_day.value_foreign_buy,
          sum_value_foreign_sell: trading_day.value_foreign_sell,
          sum_value_foreign_net: trading_day.value_foreign_net,
          sum_volume_foreign_net: trading_day.volume_foreign_net,
          sum_volume_foreign_buy: trading_day.volume_foreign_buy,
          sum_volume_foreign_sell: trading_day.volume_foreign_sell,
          sum_value_proprietary_buy: trading_day.value_proprietary_buy,
          sum_value_proprietary_sell: trading_day.value_proprietary_sell,
          sum_share_listed: trading_day.share_listed,
          share_foreign_max_allowed: trading_day.share_foreign_max_allowed,
          share_foreign_add_allowed: trading_day.share_foreign_add_allowed,
          # foreign_own_sub_percent: (
          #   if trading_day.share_foreign_max_allowed && trading_day.share_foreign_add_allowed && trading_day.share_listed.to_i > 0
          #     (((trading_day.share_foreign_max_allowed.to_f - trading_day.share_foreign_add_allowed.to_f) / trading_day.share_listed.to_f) * 100).round(2)
          #   else
          #     nil
          #   end
          # )

          foreign_own_sub_percent: (
            if trading_day&.share_foreign_max_allowed && trading_day&.share_foreign_add_allowed && trading_day&.share_listed.to_i > 0
              (((trading_day.share_foreign_max_allowed.to_f - trading_day.share_foreign_add_allowed.to_f) / trading_day.share_listed.to_f) * 100).round(2)
            else
              nil
            end
          )
        }
      }
    end
  end

  def aggregate_5d
    # Get the last 5 trading dates (descending)
    last_5_dates = StockTradingDay.order(trading_date: :desc).distinct.pluck(:trading_date).uniq.first(5)

    # For each ticker, aggregate over the last 5 days
    @aggregated_records = Ticker.includes(:group).map do |ticker|
      days = ticker.stock_trading_days.where(trading_date: last_5_dates)
      next if days.empty?
      last_day = days.order(trading_date: :desc).first
      {
        ticker: ticker,
        aggregate: {
          last_price_close: last_day&.price_close,
          last_share_listed: last_day&.share_listed,
          last_share_foreign_own_rate: last_day&.share_foreign_own_rate,
          sum_price_change: days.sum(:price_change),
          sum_price_change_pct: days.sum(:price_change_pct),
          sum_volume_total: days.sum(:volume_total),
          sum_volume_negotiated: days.sum(:volume_negotiated),
          sum_value_total: days.sum(:value_total),
          sum_value_negotiated: days.sum(:value_negotiated),
          sum_value_foreign_net: days.sum(:value_foreign_net),
          sum_volume_foreign_net: days.sum(:volume_foreign_net),
          sum_value_foreign_buy: days.sum(:value_foreign_buy),
          sum_value_foreign_sell: days.sum(:value_foreign_sell),
          sum_volume_foreign_buy: days.sum(:volume_foreign_buy),
          sum_volume_foreign_sell: days.sum(:volume_foreign_sell),
          sum_value_proprietary_buy: days.sum(:value_proprietary_buy),
          sum_value_proprietary_sell: days.sum(:value_proprietary_sell),
          sum_share_listed: days.sum(:share_listed),
          share_foreign_max_allowed: last_day&.share_foreign_max_allowed,
          share_foreign_add_allowed: last_day&.share_foreign_add_allowed,
          foreign_own_sub_percent: (
            if last_day&.share_foreign_max_allowed && last_day&.share_foreign_add_allowed && last_day&.share_listed.to_i > 0
              (((last_day.share_foreign_max_allowed.to_f - last_day.share_foreign_add_allowed.to_f) / last_day.share_listed.to_f) * 100).round(2)
            else
              nil
            end
          )
        }
      }
    end.compact.sort_by { |rec| rec[:ticker].symbol }
    render :"5d"
  end
end
