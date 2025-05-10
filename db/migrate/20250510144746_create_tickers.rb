class CreateTickers < ActiveRecord::Migration[8.0]
  def change
    create_table :tickers do |t|
      t.string :symbol, null: false
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
