require '../db_connect'
require '../model/stock_short_term_info'
stocks = StockShortTermInfo.select("id,code,symbol,name,industry,latest_report_date").where("code=?", '600252').distinct
stock=stocks.first
stock.update(latest_report_date: '2014-04-30 00:00:00')
