require '../crawler/stock_report_info_crawler'
require '../model/stock_short_term_info'
require '../util/constant'
require 'logger'
require 'yaml'
class StockReportInfoController
  REPORT_TYPE=["vFD_BalanceSheet", "vFD_ProfitStatement", "vFD_CashFlow"]


  REPORT_NAME_MAP=YAML.load(Constant::PROJECT_ROOT)+'/config/report_property.yml'


  def get_stock_ids
    StockShortTermInfo.select("code").group("code")
  end

  def dispatch_tasks
    stock_ids = get_stock_ids
    stock_report_info_crawler = StockReportInfoCrawler.new
    stock_ids.each do |stock_id|
      REPORT_TYPE.each do |type|
        for year in 2006...2014
          begin
            stock_array = Array.new
            url = "http://vip.stock.finance.sina.com.cn"
            path="/corp/go.php/"+type+"/stockid/"+stock_id+"/ctrl/"+year+"/displaytype/4.phtml"
            stock_report_json = MultiJson.load(stock_report_info_crawler.get_stock_report_hash(url, path))["stockinfos"]
            sleep(rand(3)+1)
            stock_report_json.each do |elem|
              for i in 0...elem["datas"].length-1
                if stock_array[i]==nil
                  stock_array[i]=Hash.new
                  stock_array[i]["code"]=stock_id
                end
                stock_array[i][REPORT_NAME_MAP[elem["name"]]]=elem["datas"][i]
              end
            end
            if type=="vFD_BalanceSheet"
              BalanceSheetReport.create(stock_array)
            elsif type="vFD_ProfitStatement"
              ProfitStatementReport.create(stock_array)
            elsif type="vFD_CashFlow"
              CashFlowReport.create(stock_array)
            end
          rescue Exception => e
            STOCK_DAY_INFO_LOG.error "Error in crawlReportInfo!: #{e}"+"\n"+e.backtrace.join("\n")
          end
        end

      end

    end
  end
end
STOCK_DAY_INFO_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/stock_long_term_info.log', 0, 10 * 1024 * 1024)
stock_report_info_controller = StockReportInfoController.new
stock_report_info_controller.dispatch_tasks
