class AddIsSingleQuarterToReport
  def change
    add_column :balance_sheet_reports, :is_single_quarter, :boolean
    add_column :profit_statement_reports, :is_single_quarter, :boolean
    add_column :cash_flow_reports, :is_single_quarter, :boolean
  end
end