class Ticker < ApplicationRecord
  belongs_to :group
  has_many :stock_records
end
