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
        profit_statement_report.instance_values.each do |name|
          if stock_array[i].instance_variable_get(name).kind_of? Numeric
            profit_statement_report.instance_variable_set(name, stock_array[i].instance_variable_get(name)-stock_array[i+1].instance_variable_get(name))
          else
            profit_statement_report.instance_variable_set(name, stock_array[i].instance_variable_get(name))
          end

        end
        earning_quarterly = stock_array[i].net_profit-stock_array[i+1].net_profit
        profit_statement_report.basic_earnings_per_share_yuan=earning_quarterly/(stock_array[i].net_profit/stock_array[i].basic_earnings_per_share_yuan)
        profit_statement_report.diluted_earnings_per_share_yuan = earning_quarterly/(stock_array[i].net_profit/stock_array[i].diluted_earnings_per_share_yuan)
        profit_statement_report.is_single_quarter=true
        profit_statement_report.save
      end
    end
  end

end