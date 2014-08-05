require 'require_all'
require_all '../model/*.rb'
require_all '../analysis/*.rb'
require 'logger'
require '../util/constant'
require '../crawler/investor_crawler'
class CanslimReport
  PROPERTY_NAME_MAP=YAML.load(File.open(Constant::PROJECT_ROOT+'/config/Time_Setting.yml'))

  def report

    filter_collect = FilterCollect.new
    canslim_filter = CanslimFilter.new
    array = Array.new
    learders_hash = FilterCollect.array_to_hash(canslim_filter.l_filter(PROPERTY_NAME_MAP["leaders_time"]))
    a_hash = FilterCollect.array_to_hash(canslim_filter.a_filter(PROPERTY_NAME_MAP["a_years"]))
    c_hash = FilterCollect.array_to_hash(canslim_filter.c_filter(PROPERTY_NAME_MAP["c_this_quarter"], PROPERTY_NAME_MAP["c_last_year_quarter"]))
    roe_dar_hash = FilterCollect.array_to_hash(OtherBasicFilter.new.roe_dar_filter)


    array<<c_hash<<a_hash<<roe_dar_hash<<learders_hash
    result = filter_collect.filter_combine_result(array)
    CANSLIM_LOG.info "count:"+result.length.to_s+"  these are filter combine result below:code     name            industry                annual_earnings_increase        current_quarterly_earnings              roe                      dar           rs    changePercent"
    agent =Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'
    invest_c = InvestorCrawler.new(agent)
    result.each_value do |value|
      CANSLIM_LOG.info value.code.to_s+"   "+value.name.to_s+"     "+value.industry.to_s+"    "+value.annual_earnings_increase.to_s+"      "+value.current_quarterly_earnings.to_s+"     "+value.roe.to_s+"       "+value.dar.to_s+"         "+value.rs.to_s+"        "+value.changepercent.to_s+"    ---"
      symb = nil
      if value.code.to_s=~/^60\d+/ || value.code.to_s=~/^90\d+/
        symb = 'sh'+value.code.to_s
      else
        symb='sz'+value.code.to_s
      end
      institution_hash = invest_c.crawl_institution_investors('http://data.eastmoney.com', '/zlsj/detail/201406/'+symb.to_s+'.html')
      CANSLIM_LOG.info institution_hash
      sr = 'http://data.eastmoney.com', '/executive/xml/'+value.code.to_s+'.xml'
      executive_hash = invest_c.crawl_manage_investors('http://data.eastmoney.com', '/executive/xml/'+value.code.to_s+'1.xml')
      CANSLIM_LOG.info executive_hash
    end
  end
end
CANSLIM_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/canslim_filter.log', 0, 10 * 1024 * 1024)
reportor = CanslimReport.new
reportor.report