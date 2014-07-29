require 'wombat'
require 'logger'
require '../util/constant'
class StockLongTermInfoCrawler

#from hexun  http://datainfo.stock.hexun.com/shgs/hqsj/jdtj.aspx?selectedItem=newPrice&page=1&indexTable=3690&selectedDate=DESC
  def crawl_stock_long_term_info(base_url, path)
    begin
      stocks_hash = Wombat.crawl do
        base_url base_url
        path path

        stockinfos "xpath=//table[@id='MyTable']/tr", :iterator do
          name "xpath=./td[1]"
          code "xpath=./td[2]"
          trade "xpath=./td[3]"
          volume "xpath=./td[4]"
          amount "xpath=./td[5]"
          changepercent "xpath=./td[6]"
          turnoverratio "xpath=./td[7]"
          amplitude "xpath=./td[8]"
          high "xpath=./td[9]"
          low "xpath=./td[10]"
          # report_time report_time
          # period period
        end
      end
    rescue Exception => e
      STOCK_LONG_TERM_INFO_LOG.info "Error in crawl_stock_day_info:  "+e.message+"\n"+e.backtrace.join("\n")
    end
    stocks_hash
  end
end

STOCK_LONG_TERM_INFO_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/stock_long_term_info.log', 0, 10 * 1024 * 1024)

stock_long_term_info_crawler = StockLongTermInfoCrawler.new
hash = stock_long_term_info_crawler.crawl_stock_long_term_info('http://datainfo.stock.hexun.com', '/shgs/hqsj/jdtj.aspx?selectedItem=newPrice&page=1&indexTable=3690&selectedDate=DESC')
puts hash