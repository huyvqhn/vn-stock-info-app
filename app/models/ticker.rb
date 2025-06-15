class Ticker < ApplicationRecord
  belongs_to :group
  has_many :stock_prices

  validates :symbol, presence: true, uniqueness: true
end
