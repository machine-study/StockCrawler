class AddLatestReportTimeToLongTime< ActiveRecord::Migration
  def change
    add_column :stock_short_term_infos, :latest_report_date, :timestamp
  end
end