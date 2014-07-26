require '../db_connect'
require '../model/stock_short_term_info'
class StockShortTermService
  def StockShortTermService.get_stocks
    # StockShortTermInfo.select("code,name,industry").distinct.offset(2070)
    StockShortTermInfo.select("code,name,industry").distinct
  end

  def StockShortTermInfo.get_stocks_by_time(begin_time,end_time)
    StockShortTermInfo.select.where(ticktime: begin_time..end_time)
  end
end