class CreateStockShortTermInfos < ActiveRecord::Migration
  def change
    create_table :stock_short_term_infos do |t|
      t.string :symbol
      t.string :code
      t.string :name
      t.string :industry
      t.integer :trade
      t.float :pricechange
      t.float :changepercent
      t.float :buy
      t.float :sell
      t.float :settlement
      t.float :open
      t.float :high
      t.float :low
      t.integer :volume
      t.float :amount
      t.time :ticktime
      t.float :per
      t.float :pb
      t.float :mktcap
      t.float :nmc
      t.float :turnoverratio
      t.timestamps
    end
    add_index :stock_short_term_infos, [:code, :ticktime], :unique => true

  end
end