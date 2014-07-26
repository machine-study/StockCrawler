class InvestorController
  def dispatch_tasks
    begin
      stocks = StockShortTermService.get_stocks
      puts stocks.length
      stock_report_info_crawler = StockReportInfoCrawler.new
    rescue Exception => e
    end
  end
end