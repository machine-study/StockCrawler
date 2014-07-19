require 'require_all'
require_all '../model/*.rb'
require '../util/constant'
require '../util/time_util'
require 'logger'
require '../db_connect'

class CanslimFilter
  def c_filter(this_quarter, last_year_quarter)
    STOCK_DAY_INFO_LOG.info "These stocks C more than 50% below:"
    ProfitStatementReport.select("id,code,industry,name,diluted_earnings_per_share_yuan").where("report_date=?", this_quarter).find_each do |this_year_stock|
      last_year_stock=ProfitStatementReport.select("id,code,industry,name,diluted_earnings_per_share_yuan").where("code=? AND report_date=?", this_year_stock.code, last_year_quarter).first
      if this_year_stock.diluted_earnings_per_share_yuan==nil || last_year_stock.diluted_earnings_per_share_yuan==nil ||last_year_stock.diluted_earnings_per_share_yuan==0
        next
      end
      c_rate = (this_year_stock.diluted_earnings_per_share_yuan-last_year_stock.diluted_earnings_per_share_yuan)/last_year_stock.diluted_earnings_per_share_yuan
      if c_rate>1
        result = this_year_stock.code.to_s+"    "+this_year_stock.name.to_s+"    "+this_year_stock.industry.to_s+"    "+c_rate.to_s
        STOCK_DAY_INFO_LOG.info result
      end
    end
  end

  def a_filter(year_ago)
    STOCK_DAY_INFO_LOG.info "These stocks A more than 25% below:"
    last_year = TimeUtil.get_last_n_year_end(1)
    last_six_year = TimeUtil.get_last_n_year_end(year_ago)
    stock_hash=Hash.new
    ProfitStatementReport.select("id,code,industry,report_date,name,diluted_earnings_per_share_yuan").where("report_date>=? AND report_date<=?", last_six_year,last_year).find_each do |stock|
      if stock_hash[stock.code]==nil
        stock_hash[stock.code]=Array.new
      end
      stock_hash[stock.code]<<stock
    end
    stock_hash.each do |code, stock_array|
      try
      stock_array.sort! { |a, b| a.report_date <=> b.report_date }
      if stock_array.length<year_ago
        STOCK_DAY_INFO_LOG.warn "code "+code+"length is less than "+year_ago.to_s
      end
      compounded_growth_rate = 0
      e_first = stock_array[0].diluted_earnings_per_share_yuan
      e_last = stock_array[stock_array.length-1].diluted_earnings_per_share_yuan
      if e_first!=nil&&e_last!=nil&&e_last>0 && e_first>0
        compounded_growth_rate=(e_last/e_first)**Rational(1, year_ago)-1
      end
      if compounded_growth_rate>0.25
        result = stock_array[0].code+" "+stock_array[0].name+" "+stock_array[0].industry+" the compounded growth rate is "+compounded_growth_rate.to_s+" "+stock_array[0].report_date.to_s+" is "+e_first.to_s+" "+stock_array[stock_array.length-1].report_date.to_s+" is "+e_last.to_s
        STOCK_DAY_INFO_LOG.info result
      end

    end

  end
end

STOCK_DAY_INFO_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/canslim_filter.log', 0, 10 * 1024 * 1024)
canslim_filter = CanslimFilter.new
# canslim_filter.c_filter("2014-03-31 00:00:00", "2013-03-31 00:00:00")
canslim_filter.a_filter(5)