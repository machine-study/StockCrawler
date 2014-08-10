require '../db_connect'
require '../model/stock_short_term_info'
class StockShortTermService
  def StockShortTermService.get_stocks(report_date)
    # StockShortTermInfo.select("code,name,industry").distinct.offset(2070)
    StockShortTermInfo.where("latest_report_date<?",report_date).select("id,code,symbol,name,industry,latest_report_date").distinct
  end

  def StockShortTermService.get_stocks_by_time(begin_time,end_time)
    StockShortTermInfo.select.where(ticktime: begin_time..end_time)
  end
end