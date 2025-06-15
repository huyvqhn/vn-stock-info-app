class StockTradingDay < ApplicationRecord
  belongs_to :ticker

  # Validations
  validates :trading_date, presence: true
  validates :price_open, :price_high, :price_low, :price_close, presence: true, numericality: true

  # Callbacks
  before_save :calculate_derived_fields

  private

  def calculate_derived_fields
    calculate_volumes
    calculate_values
    calculate_foreign_trading
    calculate_proprietary_trading
  end

  def calculate_volumes
    # Total volume is the sum of matched and negotiated volumes
    self.volume_total = (volume_match || 0) + (volume_negotiated || 0)
  end

  def calculate_values
    # Total value is the sum of matched and negotiated values
    self.value_total = (value_match || 0) + (value_negotiated || 0)
  end

  def calculate_foreign_trading
    # Foreign net volume
    self.volume_foreign_net = (volume_foreign_buy || 0) - (volume_foreign_sell || 0)

    # Foreign net value
    self.value_foreign_net = (value_foreign_buy || 0) - (value_foreign_sell || 0)
  end

  def calculate_proprietary_trading
    # Proprietary net volume
    self.volume_proprietary_net = (volume_proprietary_buy || 0) - (volume_proprietary_sell || 0)

    # Proprietary net value
    self.value_proprietary_net = (value_proprietary_buy || 0) - (value_proprietary_sell || 0)
  end
end
