require 'wombat'
require 'open-uri'
require 'multi_json'
class StockDayInfoCrawler
end
out = Wombat.crawl do
  # base_url "http://vip.stock.finance.sina.com.cn"
  # path "/quotes_service/api/json_v2.php/Market_Center.getHQNodes"

  # industries "xpath=//*"
  m = Mechanize.new
  mp = m.get 'http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodes'

  page mp
end
puts out

# http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=3&num=40&sort=symbol&asc=1&node=new_swzz&symbol=&_s_r_a=page