require 'require_all'
require_all '../model/*.rb'
require '../util/constant'
require '../util/time_util'
require 'logger'
require '../db_connect'

class OtherBasicFilter
  def roe_dar_filter
    last_year = TimeUtil.get_last_n_year_end(1).to_s
    stock_analysis_array = Array.new
    BalanceSheetReport.select("id,code,industry,report_date,name,total_liabilities,shareholders_equity_combined,liabilities_and_shareholders_equity_in_total").where("report_date=?", last_year).find_each do |b_stock|
      dar = b_stock.total_liabilities/b_stock.liabilities_and_shareholders_equity_in_total
      if dar<0.7
        # ProfitStatementReport.select("id,code,industry,report_date,name,net_profit,diluted_earnings_per_share_yuan").where("report_date=? and code=?", last_year, b_stock.code).find_each do |p_stock|
        CashFlowReport.select("id,code,industry,report_date,name,net_profit,net_amount_of_cash_flow_that_the_business_activities_generate").where("report_date=? and code=?", last_year, b_stock.code).find_each do |p_stock|
          roe = p_stock.net_profit/b_stock.shareholders_equity_combined
          if roe>0.17 && p_stock.net_amount_of_cash_flow_that_the_business_activities_generate>p_stock.net_profit
            stock_analysis = StockAnalysis.new
            stock_analysis.code = p_stock.code
            stock_analysis.name = p_stock.name
            stock_analysis.industry = p_stock.industry
            stock_analysis.roe =roe
            stock_analysis.dar =dar
            stock_analysis_array<<stock_analysis
            CANSLIM_LOG.info p_stock.code.to_s+" "+p_stock.name.to_s+" "+p_stock.industry.to_s+" "+dar.to_s+" "+roe.to_s
          end
        end
      end
    end
    stock_analysis_array.sort! { |x, y| y.roe<=>x.roe }

  end
end

CANSLIM_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/canslim_filter.log', 0, 10 * 1024 * 1024)
other_basic_filter = OtherBasicFilter.new
other_basic_filter.roe_dar_filter

