class AddExchangeSectorIndustryIsActiveToTickers < ActiveRecord::Migration[6.1]
  def change
    add_column :tickers, :exchange, :string
    add_column :tickers, :sector, :string
    add_column :tickers, :industry, :string
    add_column :tickers, :is_active, :boolean, default: true
  end
end
