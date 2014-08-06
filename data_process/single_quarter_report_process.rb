class SingleQuarterReportProcess
  def get_profit_statement_map(start_time, end_time)
    stock_map = Hash.new
    ProfitStatementReport.select.where(report_date: start_time..end_time).find_each do |stock|
      if stock_map[stock.code]==nil
        stock_map[stock.code]=Array.new
      end
      stock_map[stock.code]<<stock
    end
    stock_map.each_value do |stock_array|
      stock_array.sort! { |a, b| b.report_date <=> a.report_date }
    end
  end

  def set_quarterly_profit_statement(stock_map)
    quarter_stock_array = Array.new
    stock_map.each_value do |stock_array|
      for i in 0...stock_array.length-1
        profit_statement_report = ProfitStatementReport.new
        profit_statement_report.code = stock_array[i].code
        profit_statement_report.gross_revenue = stock_array[i].gross_revenue-stock_array[i+1].gross_revenue

      end
    end
  end

end