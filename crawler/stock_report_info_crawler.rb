require 'wombat'
require 'open-uri'
require 'multi_json'
# http://money.finance.sina.com.cn/corp/go.php/vFD_ProfitStatement/stockid/600079/ctrl/part/displaytype/4.phtml
class StockReportInfoCrawler
  include Wombat::Crawler


  # def initialize(base_url, path)
  #   @base_url=base_url
  #   @path=path
  #   @main_page=nil
  # end

base_url "http://money.finance.sina.com.cn"
path "/corp/go.php/vFD_ProfitStatement/stockid/600079/ctrl/part/displaytype/4.phtml"

stockinfos "xpath=//table[@id='ProfitStatementNewTable0']/tbody/tr[./td[@style='text-align:right;']]", :iterator do
  name "xpath=./td[1]"
  datas "xpath=./td[position()>1]", :list
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
crawler = StockReportInfoCrawler.new
puts crawler.crawl