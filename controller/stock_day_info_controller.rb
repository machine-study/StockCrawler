require '../crawler/stock_day_info_crawler'
require 'logger'
require '../db_connect'
class StockDayInfoController
  def crawlIndustries
    STOCK_DAY_INFO_LOG.info "start to crawlIndustries"
    industries_json=nil
    begin
      client = Mechanize.new
      page = client.get('http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodes', :headers => {'Content-Type' => 'text/plain; charset=gb2312'})
      result = Iconv.conv('utf-8', "gb2312", page.body)
      industries_json = MultiJson.load(result)
    rescue Exception => e
      STOCK_DAY_INFO_LOG.error "Error in crawlIndustries!: #{e}"+"\n"+e.backtrace.join("\n")
    end
    STOCK_DAY_INFO_LOG.info "finish crawlIndustries"
    industries_json
  end

  def dispatch_url
    begin
      STOCK_DAY_INFO_LOG.info "start to dispatch url tasks"
      agent =Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      stock_day_info_crawler = StockDayInfoCrawler.new(agent)
      industries_json = crawlIndustries
      sina_industries = industries_json[1][0][1][0][1]
      for i in 0...sina_industries.length-1
        STOCK_DAY_INFO_LOG.info "start to dispatch url task of #{ sina_industries[i][0]}"
        begin
          page_no = 1
          result = true
          while result
            url = "http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page="+page_no.to_s+"&num=80&sort=symbol&asc=1&node="+sina_industries[i][2]+"&symbol= &_s_r_a=page"
            result = stock_day_info_crawler.crawl_stock_day_info(url, sina_industries[i][0])
            page_no+=1
          end
        rescue Exception => e
          STOCK_DAY_INFO_LOG.error "Error in crawl stockInfo of #{sina_industries[i][0]} industry!: #{e}"+"\n"+e.backtrace.join("\n")
        end
        STOCK_DAY_INFO_LOG.info "finish dispatch url task of #{ sina_industries[i][0]}"
      end
    rescue Exception => e
      STOCK_DAY_INFO_LOG.error "Error in dispatch url: #{e} "+"\n"+e.backtrace.join("\n")
    end
    STOCK_DAY_INFO_LOG.info "finish dispatch url tasks"
  end
end
project_root = File.dirname(File.absolute_path(__FILE__))

project_root = project_root.slice(0, project_root.index("StockCrawler")+12)
STOCK_DAY_INFO_LOG=Logger.new(project_root+'/logs/stock_day_info.log', 0, 10 * 1024 * 1024)
stock_day_info_controller = StockDayInfoController.new
stock_day_info_controller.dispatch_url

# http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=2&num=80&sort=symbol&asc=1&node=new_jtys&symbol=&_s_r_a=page