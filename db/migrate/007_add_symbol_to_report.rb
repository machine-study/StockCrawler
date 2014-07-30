class AddSymbolToReport< ActiveRecord::Migration
  def change
    add_column :balance_sheet_reports, :symbol, :string
    add_column :profit_statement_reports, :symbol, :string
    add_column :cash_flow_reports, :symbol, :string
    add_index :balance_sheet_reports, [:symbol, :report_date], :unique => true
    add_index :profit_statement_reports, [:symbol, :report_date], :unique => true
    add_index :cash_flow_reports, [:symbol, :report_date], :unique => true
  end
end