class AddIsSingleQuarterToReport< ActiveRecord::Migration
  def change


    add_index :balance_sheet_reports, [:code, :report_date, :is_single_quarter], :unique => true,:name=>'quarter_index'
    add_index :profit_statement_reports, [:code, :report_date, :is_single_quarter], :unique => true,:name=>'quarter_index'
    add_index :cash_flow_reports, [:code, :report_date, :is_single_quarter], :unique => true,:name=>'quarter_index'


  end
end