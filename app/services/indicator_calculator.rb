class IndicatorCalculator
  # --- RSI ---
  # Full RSI calculation for the first N+1 closes
  def self.rsi_full(prices, period = 14)
    return nil if prices.size < period + 1
    gains = []
    losses = []
    (1..period).each do |i|
      change = prices[i] - prices[i - 1]
      gains << [ change, 0 ].max
      losses << [ -change, 0 ].max
    end
    avg_gain = gains.sum.to_f / period
    avg_loss = losses.sum.to_f / period
    return 100.0 if avg_loss == 0
    rs = avg_gain / avg_loss
    (100 - (100 / (1 + rs))).round(2)
  end

  # Rolling RSI calculation for subsequent days
  def self.rsi_rolling(prev_avg_gain, prev_avg_loss, current_gain, current_loss, period = 14)
    avg_gain = ((prev_avg_gain * (period - 1)) + current_gain) / period
    avg_loss = ((prev_avg_loss * (period - 1)) + current_loss) / period
    return 100.0 if avg_loss == 0
    rs = avg_gain / avg_loss
    (100 - (100 / (1 + rs))).round(2)
  end

  # --- Moving Average (MA) ---
  # Placeholder for Moving Average logic
  def self.moving_average(prices, period)
    return nil if prices.size < period
    prices.last(period).sum.to_f / period
  end

  # Initial (full) Moving Average calculation
  def self.ma_full(values, period)
    return nil if values.size < period
    values.last(period).sum.to_f / period
  end

  # Efficient (rolling) Moving Average calculation
  def self.ma_rolling(prev_ma, prev_value, new_value, period)
    # prev_ma: previous MA value
    # prev_value: value that is leaving the window
    # new_value: value that is entering the window
    prev_ma + (new_value - prev_value).to_f / period
  end

  # --- MACD ---
  # Placeholder for MACD logic
  def self.macd(prices, short_period = 12, long_period = 26, signal_period = 9)
    # MACD calculation logic here
  end

  # Initial (full) MACD calculation
  def self.macd_full(prices, short_period = 12, long_period = 26)
    return nil if prices.size < long_period
    ema_short = ema_full(prices, short_period)
    ema_long = ema_full(prices, long_period)
    return nil unless ema_short && ema_long
    ema_short - ema_long
  end

  # Efficient (rolling) MACD calculation
  def self.macd_rolling(prev_ema_short, prev_ema_long, new_price, short_period = 12, long_period = 26)
    ema_short = ema_rolling(prev_ema_short, new_price, short_period)
    ema_long = ema_rolling(prev_ema_long, new_price, long_period)
    ema_short - ema_long
  end

  # --- MACD Signal ---
  # MACD Signal calculation (using EMA of MACD values)
  def self.macd_signal_full(macd_values, signal_period = 9)
    ema_full(macd_values, signal_period)
  end

  def self.macd_signal_rolling(prev_ema_signal, new_macd, signal_period = 9)
    ema_rolling(prev_ema_signal, new_macd, signal_period)
  end

  # --- EMA Helper ---
  # Full EMA calculation
  def self.ema_full(values, period)
    return nil if values.size < period
    k = 2.0 / (period + 1)
    ema = values.first(period).sum.to_f / period
    values[period..-1].each do |price|
      ema = price * k + ema * (1 - k)
    end
    ema
  end

  # Rolling EMA calculation
  def self.ema_rolling(prev_ema, new_value, period)
    k = 2.0 / (period + 1)
    new_value * k + prev_ema * (1 - k)
  end

  # --- Volume MA ---
  # Volume Moving Average calculation (using full MA method)
  def self.volume_ma_full(volumes, period)
    ma_full(volumes, period)
  end

  # Volume MA calculation (efficient/rolling method)
  def self.volume_ma_rolling(prev_ma, prev_value, new_value, period)
    ma_rolling(prev_ma, prev_value, new_value, period)
  end

  # Generic SMA calculation
  def self.sma(values, period)
    return nil if values.size < period
    values.last(period).sum.to_f / period
  end

  # Generic pivot point detector
  # Params:
  # - stock_trading_days: Array of StockTradingDay objects, sorted by date ascending
  # - sell_col: Symbol or string for the sell column (e.g., :value_foreign_sell)
  # - net_col: Symbol or string for the net column (e.g., :value_foreign_net)
  # - sma_period: Integer, period for SMA (default: 20)
  # Returns: Array of trading_date where pivot detected
  def self.detect_pivot_points(stock_trading_days, sell_col:, net_col:, sma_period: 20)
    pivot_points = []
    return pivot_points if stock_trading_days.size < sma_period + 2

    # Precompute SMA for net_col
    net_values = stock_trading_days.map { |d| d.send(net_col).to_f }
    sma_values = []
    stock_trading_days.each_with_index do |day, idx|
      if idx >= sma_period
        sma_values << net_values[(idx - sma_period)...idx].sum / sma_period
      else
        sma_values << nil
      end
    end

    stock_trading_days.each_cons(2).with_index do |(prev, curr), idx|
      next if idx < sma_period # skip until SMA is available
      prev_sma = sma_values[idx]
      curr_net = curr.send(net_col).to_f
      curr_sell = curr.send(sell_col).to_f
      prev_net = prev.send(net_col).to_f
      prev_sell = prev.send(sell_col).to_f

      if prev_sell > curr_sell &&
         prev_net < 0 &&
         curr_net > 0 &&
         prev_sma && curr_net > prev_sma
        pivot_points << curr.trading_date
      end
    end

    pivot_points
  end
end
