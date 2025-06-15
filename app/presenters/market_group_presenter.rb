# frozen_string_literal: true

class MarketGroupPresenter
  def initialize
    # @ticker_hash = ticker_hash
    # @tickers_results = tickers_results
  end

  def group_results(group_hash, tickers_results)
    adjusted_results = adjusted_tickers_results(tickers_results).index_by { |t| t["symbol"] }

    groups_tickers = group_hash.transform_values do |symbols|
      symbols.map { |symbol| adjusted_results[symbol] }.compact
             .sort_by { |stock| stock["value_foreign_net"].to_s.delete(",").to_f }
             .reverse # descending order
    end

    groups_tickers

    # Rails.logger.info(groups_tickers)
  end

  def top_30_results(tickers_results)
    adjusted_results = adjusted_tickers_results(tickers_results).index_by { |t| t["symbol"] }

    adjusted_results.values.sort_by { |stock| stock["value_foreign_net"].to_s.delete(",").to_f }.reverse.first(30)
  end

  # app/presenters/market_group_presenter.rb
  def self.row_color(change_percent)
    percent = change_percent.to_f
    if percent > 6
      "#CBC3E3"
    elsif percent > 4
      "#83f28f"
    elsif percent > 2
      "#b2ffb2"
    elsif percent > 0
      "#e5ffe5"
    elsif percent > -1
      "#FFF4F3"
    elsif percent > -2
      "#FFADB0"
    elsif percent > -6
      "#FF999C"
    else
      "#90D5FF"
    end
  end

  private


  def adjusted_tickers_results(tickers_results)
    tickers_results.map do |ticker|
      net_vol_nn = ticker["foreignBuy"] - ticker["foreignSell"]
      {
        "symbol" => ticker["symbol"],
        "price" => ticker["closePrice"].to_f / 1000,
        "percent_change" => "#{(ticker['changePercent'].to_f).round(2)}%",
        "volume_foreign_matching" => represent_number(net_vol_nn),
        "value_foreign_net" => represent_number(net_vol_nn * ticker["averagePrice"]),
        "percent_Trans" => ticker["ListedShare"].present? || ticker["ListedShare"].to_f.zero? ?
                             "" : "#{((net_vol_nn.to_f / ticker['ListedShare'].to_f) * 100).round(2)}%",
        "volume_total" => represent_number(ticker["totalTrading"]),
        "all_matching" => represent_number(ticker["totalTradingValue"]),
        "percent_vol_nn" => ticker["totalTrading"].to_f.zero? ?
                              "0%" : "#{((net_vol_nn.to_f / ticker['totalTrading']) * 100).round(2)}%",
        "percent_match_over_all_shares" => ticker["ListedShare"].present? && ticker["ListedShare"].to_f > 0 ?
                                             "#{((ticker['totalTrading'].to_f / ticker['ListedShare'].to_f) * 100).round(2)}%" : "",
        "percent_own_nn" => ticker["ListedShare"].present? && ticker["ListedShare"].to_f > 0 ?
                              "#{(((ticker['foreignRoom'].to_f - ticker['foreignRemain'].to_f) / ticker['ListedShare'].to_f) * 100).round(2)}%" : "",
        "all_shares" => represent_number(ticker["ListedShare"].to_f),
        "note" => ticker["note"],
        "average_price" => ticker["average_price"],
        "recorded_at" => ticker["recorded_at"]
      }
    end
  end

  def represent_number(number)
    ActiveSupport::NumberHelper.number_to_delimited(number.to_i)
  end
end
