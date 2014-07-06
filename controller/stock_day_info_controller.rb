require '../crawler/stock_day_info_crawler'

class StockDayInfoController
  def crawlIndustries
    client = Mechanize.new
    page = client.get('http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodes', :headers => {'Content-Type' => 'text/plain; charset=gb2312'})
    result = Iconv.conv('utf-8', "gb2312", page.body)
    industries_json = MultiJson.load(result)
  end

  def dispatch_url
    stock_day_info_crawler = StockDayInfoCrawler.new(Mechanize.new)
    industries_json = crawlIndustries
    sina_industries = industries_json[1][0][1][0][1]

    for i in 0...sina_industries.length-1
      page_no = 1
      result = true
      while result
        url = "http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page="+page_no.to_s+"&num=80&sort=symbol&asc=1&node="+sina_industries[i][2]+"&symbol= &_s_r_a=page"
        result = stock_day_info_crawler.crawl_stock_day_info(url, sina_industries[i][0])
        page_no+=1
      end
    end
  end
end
stock_day_info_controller = StockDayInfoController.new
stock_day_info_controller.dispatch_url

# http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=2&num=80&sort=symbol&asc=1&node=new_jtys&symbol=&_s_r_a=page