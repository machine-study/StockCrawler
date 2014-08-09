require 'require_all'
require_all '../model/*.rb'
require '../util/constant'
require '../util/time_util'
require 'logger'
require '../db_connect'
require '../service/stock_long_term_service'

class CanslimFilter
  def c_filter(this_quarter, last_year_quarter)
    CANSLIM_LOG.info "These stocks C more than 25% below:code   name        industry         c_rate        "
    stock_analysis_array = Array.new
    ProfitStatementReport.select("id,code,industry,name,diluted_earnings_per_share_yuan").where("report_date=? and is_single_quarter=?", this_quarter,true).find_each do |this_year_stock|
      last_year_stock=ProfitStatementReport.select("id,code,industry,name,diluted_earnings_per_share_yuan").where("code=? AND report_date=? and is_single_quarter=?", this_year_stock.code, last_year_quarter,true).first
      if this_year_stock.diluted_earnings_per_share_yuan==nil || last_year_stock.diluted_earnings_per_share_yuan==nil ||last_year_stock.diluted_earnings_per_share_yuan==0
        next
      end
      c_rate = (this_year_stock.diluted_earnings_per_share_yuan-last_year_stock.diluted_earnings_per_share_yuan)/last_year_stock.diluted_earnings_per_share_yuan
      if c_rate>0.25
        stock_analysis = StockAnalysis.new
        stock_analysis.code = this_year_stock.code
        stock_analysis.name = this_year_stock.name
        stock_analysis.industry = this_year_stock.industry
        stock_analysis.current_quarterly_earnings =c_rate
        stock_analysis_array<<stock_analysis
        result = this_year_stock.code.to_s+"    "+this_year_stock.name.to_s+"    "+this_year_stock.industry.to_s+"    "+c_rate.to_s
        CANSLIM_LOG.info result
      end
    end
    stock_analysis_array.sort! { |x, y| y.current_quarterly_earnings<=>x.current_quarterly_earnings }
  end

  def a_filter(year_ago)
    CANSLIM_LOG.info "These stocks A more than 25% below:code    name     industry      growth rate         "
    last_year = TimeUtil.get_last_n_year_end(1).to_s
    last_n_year = TimeUtil.get_last_n_year_end(year_ago).to_s
    # stocks = ProfitStatementReport.select("id,code,industry,report_date,name,diluted_earnings_per_share_yuan").where("report_date=?",last_year)
    # stocks.each {|s| puts s.to_s}
    stock_hash=Hash.new
    ProfitStatementReport.select("id,code,industry,report_date,name,diluted_earnings_per_share_yuan").where(report_date: last_n_year..last_year,is_single_quarter:false).find_each do |stock|
      if stock_hash[stock.code]==nil
        stock_hash[stock.code]=Array.new
      end
      if stock.diluted_earnings_per_share_yuan!=nil && stock.diluted_earnings_per_share_yuan>0 && (stock.report_date.to_s.include? '12-31')
        stock_hash[stock.code]<<stock
      end
    end
    stock_analysis_array = Array.new
    stock_hash.each do |code, stock_array|
      stop = false
      stock_array.sort! { |a, b| b.report_date <=> a.report_date }
      if stock_array.length<year_ago
        CANSLIM_LOG.warn "code "+code+"length is less than "+year_ago.to_s
        next
      end
      for i in 0...stock_array.length-1
        inc_per_year = (stock_array[i].diluted_earnings_per_share_yuan-stock_array[i+1].diluted_earnings_per_share_yuan)/stock_array[i+1].diluted_earnings_per_share_yuan
        if inc_per_year<0.25
          stop=true
          break
        end
      end
      if stop
        next
      end
      compounded_growth_rate = 0
      e_last = stock_array[0].diluted_earnings_per_share_yuan
      e_first = stock_array[stock_array.length-1].diluted_earnings_per_share_yuan
      compounded_growth_rate=(e_last/e_first)**Rational(1, (year_ago-1))-1
      if compounded_growth_rate>0.25
        stock_analysis = StockAnalysis.new
        stock_analysis.code = stock_array[0].code
        stock_analysis.name = stock_array[0].name
        stock_analysis.industry = stock_array[0].industry
        stock_analysis.annual_earnings_increase =compounded_growth_rate
        stock_analysis_array<<stock_analysis
        result = stock_array[0].code.to_s+" "+stock_array[0].name.to_s+" "+stock_array[0].industry.to_s+" the compounded growth rate is "+compounded_growth_rate.to_s+" "+stock_array[0].report_date.to_s+" is "+e_first.to_s+" "+stock_array[stock_array.length-1].report_date.to_s+" is "+e_last.to_s
        CANSLIM_LOG.info result
      end

    end
    stock_analysis_array.sort! { |x, y| y.annual_earnings_increase<=>x.annual_earnings_increase }
  end

  def n_filter

  end

  def s_filter
  end

  def l_filter(report_time)
    stocks = StockLongTermService.get_stocks_by_time(report_time)
    length = 0.3*stocks.length
    stock_analysis_array = Array.new
    sub_stocks = stocks[0, length]
    for i in 0...sub_stocks.length
      stock_analysis = StockAnalysis.new
      stock_analysis.code = sub_stocks[i].code
      stock_analysis.name = sub_stocks[i].name
      stock_analysis.changepercent = sub_stocks[i].changepercent
      stock_analysis.rs =(stocks.length-i)*100.0/stocks.length

      stock_analysis_array<<stock_analysis

    end
    stock_analysis_array

  end

  def i_check

  end


end

CANSLIM_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/canslim_filter.log', 0, 10 * 1024 * 1024)
canslim_filter = CanslimFilter.new
# canslim_filter.c_filter("2014-03-31 00:00:00", "2013-03-31 00:00:00")

a_list = canslim_filter.a_filter(4)
# c_list = canslim_filter.c_filter("2014-03-31 00:00:00", "2013-03-31 00:00")