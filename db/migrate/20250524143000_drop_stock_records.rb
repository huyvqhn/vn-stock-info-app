class DropStockRecords < ActiveRecord::Migration[6.1]
  def change
    drop_table :stock_records, if_exists: true
  end
end
