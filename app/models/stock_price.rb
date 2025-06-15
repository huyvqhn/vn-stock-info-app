class StockPrice < ApplicationRecord
  belongs_to :ticker

  validates :price, presence: true
  # validates :volume, presence: true
  validates :recorded_at, presence: true
end
