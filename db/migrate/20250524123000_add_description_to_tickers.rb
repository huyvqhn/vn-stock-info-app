class AddDescriptionToTickers < ActiveRecord::Migration[6.1]
  def change
    add_column :tickers, :description, :string
  end
end
