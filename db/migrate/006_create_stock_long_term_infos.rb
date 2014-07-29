class CreateStockLongTermInfos < ActiveRecord::Migration
  def change
    create_table :stock_long_term_infos do |t|
      t.string :code
      t.string :name
      t.float :trade
      t.integer :volume
      t.float :amount
      t.float :changepercent
      t.float :turnoverratio
      t.float :amplitude
      t.float :high
      t.float :low
      t.integer :period
      t.timestamp :report_time
      t.timestamps
    end
    add_index :stock_long_term_infos, [:code, :period, :info_update_time], :unique => true
  end