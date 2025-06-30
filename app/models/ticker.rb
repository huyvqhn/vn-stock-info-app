class Ticker < ApplicationRecord
  belongs_to :group
  has_many :stock_prices
  has_many :stock_trading_days

  validates :symbol, presence: true, uniqueness: true

  # Returns the last 30 trading days, most recent first
  def recent_trading_days
    stock_trading_days.order(trading_date: :desc).limit(30)
  end
end
