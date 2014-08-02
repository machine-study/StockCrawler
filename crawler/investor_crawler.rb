require 'wombat'
require 'mechanize'
require 'logger'
require '../util/constant'

class InvestorCrawler
  def initialize(client)
    @client=client
  end

  # from dongfang  http://data.eastmoney.com/executive/xml/000793.xml
  def crawl_manage_investors(base_url, path)
    begin
      manage_investors_hash = Wombat.crawl do
        base_url base_url
        path path
        document_format xml

        stock_inc "xpath=//graph[@gid='0']/value", :list
        stock_dec "xpath=//graph[@gid='1']/value", :list
      end
      sleep(rand(3)+1)
    rescue Exception => e
      INVEST_CRAWL_LOG.info "Error in crawl_manage_investors:  "+e.message+"\n"+e.backtrace.join("\n")
    end
    manage_investors_hash
  end

  #from dongfang  http://data.eastmoney.com/zlsj/detail/201406/sh601318.html
  def crawl_institution_investors(base_url, path)
    institution_investors_hash = nil
    begin
      institution_investors_hash = Wombat.crawl do
        base_url base_url
        path path

        institution_investors_info "xpath=//table[@id='dt_2']/tbody/tr[last()]/td[position()>1]", :list
      end
      sleep(rand(3)+1)
    rescue Exception => e
      INVEST_CRAWL_LOG.info "Error in crawl_institution_investors:  "+e.message+"\n"+e.backtrace.join("\n")
    end
    institution_investors_hash
  end
end
INVEST_CRAWL_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/invest_crawl.log', 0, 10 * 1024 * 1024)
agent =Mechanize.new
agent.user_agent_alias = 'Linux Mozilla'
invest_c = InvestorCrawler.new(agent)
# hash = invest_c.crawl_institution_investors('http://data.eastmoney.com', '/zlsj/detail/201406/sh601318.html')
# puts hash.to_s
hash = invest_c.crawl_manage_investors('http://data.eastmoney.com', '/executive/xml/0008121.xml')
puts hash.to_s

