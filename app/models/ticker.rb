class Ticker < ApplicationRecord
  belongs_to :group
  has_many :stock_prices
  has_many :stock_trading_days

  validates :symbol, presence: true, uniqueness: true
end
