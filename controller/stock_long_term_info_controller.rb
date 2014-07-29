require 'require_all'
require '../crawler/stock_long_term_info_crawler'
require_all '../model/*.rb'
require '../util/constant'
require '../db_connect'
require 'logger'
require 'yaml'
class StockLongTermInfoController
  def crawl_date_pagecount(base_url, path)
    hash = Wombat.crawl do
      base_url base_url
      path path

      report_date "xpath=//table[//td[@id='DataWeek']]" do |e|
        date_match = /更新时间：(\d+)年(\d+)月(\d+)日/.match(e)
        date_str = date_match[1]+"-"+date_match[2]+"-"+date_match[3]+" 00:00:00"
      end
      page_count "xpath=//select[@id='sel_num']//option[last()]" do |e|
        e.to_i
      end
    end
  end

  def dispatch_url
    begin
      stock_long_term_info_crawler = StockLongTermInfoController.new
      helper_hash = crawl_date_pagecount('http://datainfo.stock.hexun.com', '/shgs/hqsj/jdtj.aspx?selectedItem=newPrice&page=1&indexTable=3690&selectedDate=DESC')
      for i in 1...helper_hash['page_count']+1
        begin
          url='http://datainfo.stock.hexun.com'
          path='/shgs/hqsj/jdtj.aspx?selectedItem=newPrice&page='+i.to_s+'&indexTable=3690&selectedDate=DESC'
          stock_hash = stock_long_term_info_crawler.crawl_date_pagecount(url, path)
          StockLongTermInfo.create(stock_hash)
        rescue Exception => e
          STOCK_LONG_TERM_INFO_LOG.info "Error in crawl_stock_long_term_info:  "+e.message+"\n"+e.backtrace.join("\n")
        end
      end
    rescue Exception => e
      STOCK_LONG_TERM_INFO_LOG.info "Error in crawl_stock_long_term_info:  "+e.message+"\n"+e.backtrace.join("\n")
    end
  end
end