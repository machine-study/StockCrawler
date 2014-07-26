class InvestorCrawler
  def initialize(client)
    @client=client
  end

  def crawl_manage_investors(base_url, path)
    begin
      investors_hash = Wombat.crawl do
        base_url base_url
        path path

        stockinfos "xpath=//table[@id='#{id}']/tbody/tr[./td[@style='text-align:right;']]", :iterator do
          name "xpath=./td[1]"
          datas "xpath=./td[position()>1]", :list
        end
      end
      sleep(rand(3)+1)
    rescue Exception => e
      STOCK_DAY_INFO_LOG.info "Error in crawl_stock_day_info:  "+e.message+"\n"+e.backtrace.join("\n")
      return false
    end
    true
  end
end