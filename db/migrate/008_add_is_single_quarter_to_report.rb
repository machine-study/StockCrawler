class AddIsSingleQuarterToReport
  def change
    add_column :balance_sheet_reports, :is_single_quarter, :boolean
    add_column :profit_statement_reports, :is_single_quarter, :boolean
    add_column :cash_flow_reports, :is_single_quarter, :boolean

    remove_index :balance_sheet_reports, [:symbol, :report_date]
    remove_index :profit_statement_reports, [:symbol, :report_date]
    remove_index :cash_flow_reports, [:symbol, :report_date]

    remove_index :balance_sheet_reports, [:code, :report_date]
    remove_index :profit_statement_reports, [:code, :report_date]
    remove_index :cash_flow_reports, [:code, :report_date]

    add_index :balance_sheet_reports, [:code, :report_date, :is_single_quarter], :unique => true
    add_index :profit_statement_reports, [:code, :report_date, :is_single_quarter], :unique => true
    add_index :cash_flow_reports, [:code, :report_date, :is_single_quarter], :unique => true


  end
end