require 'wombat'
require 'open-uri'
require 'multi_json'
require '../model/profit_statement_report'
require '../db_connect'
# http://money.finance.sina.com.cn/corp/go.php/vFD_ProfitStatement/stockid/600079/ctrl/part/displaytype/4.phtml
class StockReportInfoCrawler

  def get_stock_report_hash(base_url, path)
    products_hash = Wombat.crawl do
      base_url base_url
      path path

      stockinfos "xpath=//table[@id='ProfitStatementNewTable0']/tbody/tr[./td[@style='text-align:right;']]", :iterator do
        name "xpath=./td[1]"
        datas "xpath=./td[position()>1]", :list
      end
    end
  end

end
# out = Wombat.crawl do
#   base_url "http://money.finance.sina.com.cn"
#   path "/corp/go.php/vFD_ProfitStatement/stockid/600079/ctrl/part/displaytype/4.phtml"
#
#   stockinfos "xpath=//table[@id='ProfitStatementNewTable0']/tbody/tr[./td[@style='text-align:right;']]", :iterator do
#     name "xpath=./td[1]"
#     datas "xpath=./td[position()>1]", :list
#   end
# end
# puts out
# crawler = StockReportInfoCrawler.new
# result = crawler.get_stock_report_hash("http://money.finance.sina.com.cn", "/corp/go.php/vFD_ProfitStatement/stockid/600079/ctrl/part/displaytype/4.phtml")
# puts result["stockinfos"].class