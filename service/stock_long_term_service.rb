require '../db_connect'
require '../model/stock_short_term_info'
class StockLongTermService
  def StockLongTermService.get_stocks_by_time(report_time)
    StockLongTermInfo.select.where("report_time=?",report_time).order(changepercent: :desc)
  end
end