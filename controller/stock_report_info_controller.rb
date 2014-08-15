require 'require_all'
require '../crawler/stock_report_info_crawler'
require '../service/stock_short_term_service'
require_all '../model/*.rb'
require_all '../service/*.rb'
require '../util/constant'
require '../db_connect'
require 'logger'
require 'yaml'
class StockReportInfoController
  REPORT_TYPE=["vFD_BalanceSheet", "vFD_ProfitStatement", "vFD_CashFlow"]

  REPORT_NAME_MAP=YAML.load(File.open(Constant::PROJECT_ROOT+'/config/report_property.yml'))
  REPORT_TIME_MAP=YAML.load(File.open(Constant::PROJECT_ROOT+'/config/Time_Setting.yml'))


  def dispatch_tasks
    stocks = StockShortTermService.get_stocks(REPORT_TIME_MAP["selected_time"])
    puts stocks.length
    stock_report_info_crawler = StockReportInfoCrawler.new
    get_count = 0
    stocks.each do |stock|
      begin
        next if stock.name.include? '银行'
        for year in REPORT_TIME_MAP["year_begin"].to_i...REPORT_TIME_MAP["year_end"].to_i
          begin
            # for year in 2006...2015
            puts REPORT_TIME_MAP["year_begin"].to_s+"-" + REPORT_TIME_MAP["year_end"].to_s
            REPORT_TYPE.each do |type|
              begin
                stock_array = Array.new
                url = "http://vip.stock.finance.sina.com.cn"
                path="/corp/go.php/"+type+"/stockid/"+stock.code+"/ctrl/"+year.to_s+"/displaytype/4.phtml"
                STOCK_DAY_INFO_LOG.info "start to crawl stockInfos of: #{url}+#{path}"
                stock_report_json = stock_report_info_crawler.get_stock_report_hash(url, path)["stockinfos"]
                # puts stock_report_json
                sleep(rand(3)+1)
                stock_report_json.each do |elem|
                  for i in 0...elem["datas"].length
                    # for i in 0...1

                    if stock_array[i]==nil
                      stock_array[i]=Hash.new
                      stock_array[i]["code"]=stock.code
                      stock_array[i]["name"]=stock.name
                      stock_array[i]["symbol"]=stock.symbol
                      stock_array[i]["industry"]=stock.industry
                      stock_array[i]["is_single_quarter"]=false
                    end
                    next if elem["name"].rstrip.empty?
                    elem["name"] = elem["name"].gsub("其中:", "").gsub("其中：", "")
                    stock_array[i][REPORT_NAME_MAP[elem["name"]]]=elem["datas"][i].gsub(",", "").gsub("（元）", "")
                    if REPORT_NAME_MAP[elem["name"]]=="report_date"
                      stock_array[i]["report_date"] = stock_array[i]["report_date"]+" 00:00:00"
                    end
                  end
                end
                puts path
                stock_array.delete_if { |s| s["report_date"] < REPORT_TIME_MAP["selected_time"] }
                puts stock_array
                if stock_array.length>0
                  get_count+=1
                else
                  break
                end
                if type=="vFD_ProfitStatement"
                  ProfitStatementReport.create(stock_array)
                elsif type=="vFD_BalanceSheet"
                  BalanceSheetReport.create(stock_array)
                elsif type=="vFD_CashFlow"
                  CashFlowReport.create(stock_array)
                  stock.update_attribute('latest_report_date', stock_array[0]["report_date"])
                end
              rescue Exception => e
                STOCK_DAY_INFO_LOG.error "---Error in crawlReportInfo!: #{e}"+"\n"+e.backtrace.join("\n")
              end
              STOCK_DAY_INFO_LOG.info "finish crawling stockInfos of: #{url}+#{path}"
            end
          rescue Exception => e
            STOCK_DAY_INFO_LOG.error "------Error in crawlReportInfo!: #{e}"+"\n"+e.backtrace.join("\n")
          end
        end
      rescue Exception => e
        STOCK_DAY_INFO_LOG.error "------------Error in crawlReportInfo!: #{e}"+"\n"+e.backtrace.join("\n")
      end

    end
    STOCK_DAY_INFO_LOG.info "get count is #{get_count},the rate is "+(get_count/stocks.length.to_f).to_s
  end
end

STOCK_DAY_INFO_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/stock_long_term_info.log', 0, 10 * 1024 * 1024)
stock_report_info_controller = StockReportInfoController.new
stock_report_info_controller.dispatch_tasks
