# frozen_string_literal: true

class MarketGroupPresenter
  def initialize()
    # @ticker_hash = ticker_hash
    # @tickers_results = tickers_results
  end

  def group_results(group_hash, tickers_results)

    adjusted_results = adjusted_tickers_results(tickers_results).index_by { |t| t['symbol'] }

    groups_tickers = group_hash.transform_values do |symbols|
      symbols.map { |symbol| adjusted_results[symbol] }.compact
             .sort_by { |stock| stock['net_gd_nn'].to_s.delete(',').to_f }
             .reverse # descending order
    end

    return groups_tickers

    # Rails.logger.info(groups_tickers)
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
      net_vol_nn = ticker['foreignBuy'] - ticker['foreignSell']
      {
        'symbol' => ticker['symbol'],
        'close_price' => ticker['closePrice'].to_f / 1000,
        'change_percent' => "#{(ticker['changePercent'].to_f).round(2)}%",
        # 'net_vol_nn' => net_vol_nn,
        'net_vol_nn' => represent_number(net_vol_nn),
        'net_gd_nn' => represent_number(net_vol_nn * ticker['averagePrice'] / 1_000_000),
        'percent_Trans' => ticker['ListedShare'].present? || ticker['ListedShare'].to_f.zero? ? '' : "#{((net_vol_nn.to_f / ticker['ListedShare'].to_f) * 100).round(2)}%",
        'all_vol' => represent_number(ticker['totalTrading']),
        'all_matching' => represent_number(ticker['totalTradingValue'] / 1_000_000),
        'percent_vol_nn' => ticker['totalTrading'].to_f.zero? ? '0%' : "#{((net_vol_nn.to_f / ticker['totalTrading']) * 100).round(2)}%",
        'percent_match_over_all_shares' => ticker['ListedShare'].present? && ticker['ListedShare'].to_f > 0 ? "#{((ticker['totalTrading'].to_f / ticker['ListedShare'].to_f) * 100).round(2)}%" : '',
        'percent_own_nn' => ticker['ListedShare'].present? && ticker['ListedShare'].to_f > 0 ? "#{(((ticker['foreignRoom'].to_f - ticker['foreignRemain'].to_f) / ticker['ListedShare'].to_f) * 100).round(2)}%" : '',
        'all_shares' => represent_number(ticker['ListedShare'].to_f / 1_000_000),
        'note' => ticker['note']
      }
    end
  end

  def represent_number(number)
    ActiveSupport::NumberHelper.number_to_delimited(number)
  end
end
