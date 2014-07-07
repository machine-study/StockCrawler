require '../crawler/stock_report_info_crawler'
require 'logger'
class StockReportInfoController
  REPORT_TYPE=["vFD_BalanceSheet", "vFD_ProfitStatement", "vFD_CashFlow"]
  REPORT_NAME_MAP={"报表日期" => "report_date", "一、营业总收入" => "gross_revenue"}

  def get_stock_ids
    StockShortTermInfo.select("code").group("code")
  end

  def dispatch_tasks
    stock_ids = get_stock_ids
    stock_ids.each do |stock_id|
      REPORT_TYPE.each do |type|
        stock_array = Array.new
        url = "http://vip.stock.finance.sina.com.cn"
        path="/corp/go.php/"+type+"/stockid/"+stock_id+"/ctrl/part/displaytype/4.phtml"
        stock_report_info_crawler = StockReportInfoCrawler.new
        stock_report_json = MultiJson.load(stock_report_info_crawler.get_stock_report_hash(url, path))["stockinfos"]
        stock_report_json.each do |elem|
          for i in 0...elem["datas"].length-1
            if stock_array[i]==nil
              stock_array[i]=Hash.new
            end
            stock_array[i][elem["name"]]=elem["datas"][i]
          end
        end
        if type=="vFD_BalanceSheet"
          StockLongTermInfo.create(stock_array)
        elsif type="vFD_ProfitStatement"
        elsif type="vFD_CashFlow"
        end

      end

    end
  end
end


end