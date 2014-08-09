require 'require_all'
require_all '../model/*.rb'
require '../util/constant'
require '../util/time_util'
require 'logger'
require '../db_connect'

class SingleQuarterReportProcess
  def get_profit_statement_map(start_time, end_time)
    QUARTER_PROCESS_LOG.info "start to get_profit_statement_map"
    stock_map = Hash.new
    ProfitStatementReport.where(report_date: start_time..end_time,is_single_quarter:false).find_each do |stock|
      if stock_map[stock.code+stock.report_date.year.to_s]==nil
        stock_map[stock.code+stock.report_date.year.to_s]=Array.new
      end
      stock_map[stock.code+stock.report_date.year.to_s]<<stock
    end
    stock_map.each_value do |stock_array|
      stock_array.sort! { |a, b| b.report_date <=> a.report_date }
    end
    QUARTER_PROCESS_LOG.info "finish get_profit_statement_map"
    stock_map
  end

  def set_quarterly_profit_statement(stock_map)
    QUARTER_PROCESS_LOG.info " start to set_quarterly_profit_statement "
    quarter_stock_array = Array.new
    stock_map.each do |key, stock_array|
      begin
        QUARTER_PROCESS_LOG.info " start to set_quarterly_profit_statement of "+key
        if stock_array.length==0
          QUARTER_PROCESS_LOG.warn " stock_array of "+key+" is empty "
          next
        end

        for i in 0...stock_array.length
          begin
            if i==stock_array.length-1
              if stock_array[i].report_date.to_s.include?('03-31')
                set_first_season(stock_array, i)
              else
                QUARTER_PROCESS_LOG.warn " the last report is "+stock_array[i].report_date.to_s
              end
              break
            end
            if (stock_array[i].report_date-stock_array[i+1].report_date)/(60*60*24)>100
              QUARTER_PROCESS_LOG.warn " between the two season, days more than 100 "
              next
            end
            set_other_season(stock_array, i)
          rescue Exception => e
            QUARTER_PROCESS_LOG.error " Error in set_quarterly_profit_statement : #{e} "+"\n"+e.backtrace.join("\n")
          end
        end
        QUARTER_PROCESS_LOG.info " finish set_quarterly_profit_statement of "+key
      rescue Exception => e
        QUARTER_PROCESS_LOG.error " Error in set_quarterly_profit_statement : #{e} "+"\n"+e.backtrace.join("\n")
      end
    end
    QUARTER_PROCESS_LOG.info "finish set_quarterly_profit_statement"
  end

  private
  def set_first_season(stock_array, i)
    profit_statement_report = ProfitStatementReport.new
    attrs_exist = stock_array[i].instance_variable_get("@attributes")
    profit_statement_report.attributes =attrs_exist
    profit_statement_report.is_single_quarter=true
    profit_statement_report.id=nil
    profit_statement_report.save
  end

  def set_other_season(stock_array, i)
    profit_statement_report = ProfitStatementReport.new
    attrs = Hash.new
    attrs_exist1 = stock_array[i].instance_variable_get("@attributes")
    attrs_exist2 = stock_array[i+1].instance_variable_get("@attributes")
    attrs_exist1.each_key do |key|
      if attrs_exist1[key].kind_of? Numeric
        attrs[key]=attrs_exist1[key]-attrs_exist2[key]
      else
        attrs[key]=attrs_exist1[key]
      end
    end
    profit_statement_report.attributes =attrs
    earning_quarterly = stock_array[i].net_profit-stock_array[i+1].net_profit
    profit_statement_report.basic_earnings_per_share_yuan=earning_quarterly/(stock_array[i].net_profit/stock_array[i].basic_earnings_per_share_yuan)
    profit_statement_report.diluted_earnings_per_share_yuan = earning_quarterly/(stock_array[i].net_profit/stock_array[i].diluted_earnings_per_share_yuan)
    profit_statement_report.is_single_quarter=true
    profit_statement_report.id=nil
    profit_statement_report.save
  end

end
QUARTER_PROCESS_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/quarter_process.log', 0, 10 * 1024 * 1024)
single_quarter_report_process = SingleQuarterReportProcess.new
stock_map = single_quarter_report_process.get_profit_statement_map("2006-01-31 00:00:00", "2014-12-31 00:00:00")
single_quarter_report_process.set_quarterly_profit_statement(stock_map)

# profit_statement_report = ProfitStatementReport.new
# profit_statement_report.code="234324"
# ano = Hash.new
# attrs = profit_statement_report.instance_variable_get("@attributes")
# attrs.each_key { |k| ano[k]=attrs[k] }
# puts ano
# puts   profit_statement_report.instance_variable_get("attributes")
# profit_statement_report.instance_values.each do |name|
#   # profit_statement_report.instance_variable_set(name, stock_array[0].instance_variable_get(name))
#   puts name
# end
