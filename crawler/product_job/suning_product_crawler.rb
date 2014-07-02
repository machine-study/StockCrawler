require 'wombat'
require 'open-uri'
require 'multi_json'


  class SuningProductCrawler
    def initialize(base_url, path)
      @base_url="http://list.suning.com"
      @path="/0-330503-0-1-0-9315.html"
      @main_page=nil
    end

    def set_main_page_info
      if @main_page==nil
        base_url = @base_url
        path=@path
        @main_page=Wombat.crawl do
          base_url base_url
          path path


          pageCount1 "css=a#pageLast"

          pageCount2 "css=div.now span" do |elem|
            if elem!=nil&&!elem.empty?
              elem.split('/')[1]
            end
          end
          category1 "css=div.pb10 span"
          category2 "css=div.sn-filter-crumbs-class-li", :list do |elems|
            if elem!=nil
              elems[-1]
            end
          end
        end
      end
      puts @main_page
    end


    def crawl_every_page
      set_main_page_info
      page_count=(@main_page['pageCount1']==nil||@main_page['pageCount1'].empty?) ? @main_page['pageCount2'] : @main_page['pageCount1']
      category=(@main_page['category1']==nil||@main_page['category1'].empty?) ? @main_page['category2'] : @main_page['category1']
      for pageNum in 0...page_count.to_i
        url_segments = @path.split('-')
        url_segments[2]=pageNum
        base_url = @base_url
        path=url_segments[0]
        for len in 1...url_segments.length
          path<<"-"+url_segments[len].to_s
        end
        i=-1
        products_hash = Wombat.crawl do
          base_url base_url
          path path
          product_info_list "css=div#proShow ul>li", :iterator do
            puts "again"
            i=i+1
            product_url "xpath=//div[@class='inforBg']/span/a/@href"
            title "xpath=//div[@class='inforBg']/span/a/@title"
            rateCount "div.comment p a i"
            product_detail "xpath=//div[@class='inforBg']["+i.to_s+"]/span/a[1]", :follow do
              detail_info "css=table#pro_para_table", :html do |attr_table|
                hash={}
                attr_doc= Nokogiri::HTML(attr_table)
                tr_list = attr_doc.css("tr").select { |tr| !tr.css("th").to_html.include?("</th>") }
                attrs=''
                tr_list.each do |elem|
                  attr_name = elem.css("div.Imgpip span").inner_text.gsub("：", "").strip
                  if attr_name=="品牌"||attr_name=="产品品牌"
                    hash["brand"]=elem.css("td.td1").text
                  end
                  if attr_name=="型号"||attr_name=="产品型号"
                    hash["version"]=elem.css("td.td1").text
                  end
                  attrs += attr_name +":"+ elem.css("td.td1").text+"++"
                end
                hash["attrs"]=attrs
                puts hash
                hash
              end

              attrs_other_page "css=head" do |head_info|
                storeId_match = /"storeId":'(\d+\.??\d*?)'/.match(head_info)
                catalogId_match = /"catalogId":'(\d+\.??\d*?)'/.match(head_info)
                productId_match=/"productId":"(\d+\.??\d*?)"/.match(head_info)
                partNumber_match=/"partNumber":"(\d+\.??\d*?)"/.match(head_info)
                # hash["storeId"] = storeId_match[1]
                # hash["catalogId"] = catalogId_match[1]
                # hash["productId"] = productId_match[1]
                # hash["partNumber"] = partNumber_match[1]
                other_info_url="http://product.suning.com/email/csl_" + storeId_match[1] + "_" +catalogId_match[1] + "_" + productId_match[1] + "_"+partNumber_match[1] + "_" + "9325_.html"
                hash={}
                open(other_info_url) do |f|
                  other_info = f.read
                  other_info_json = MultiJson.load(other_info)
                  hash["original_price"]=other_info_json["shopList"][0]["productPrice"]
                  hash["discount_price"]=other_info_json["shopList"][0]["promoInfo"][0]["promoPrice"]
                end
                puts hash
                hash
              end
            end
          end
        end

        # attrs_for_other_info=product_hash["product_infolist"]["product_detail"]["attrs_for_other_info"]

        product_info_list = products_hash["product_info_list"]
        for pd_i in 0...product_info_list.length
          product = ProductConverter.hash_to_model(Product.new, product_info_list[pd_i])
          puts product.inspect
        end
        # product.save
      end
    end
  end



suning_product_crawler = SuningProductCrawler.new("http://list.suning.com", "/0-330503-0-1-0-9315.html")
suning_product_crawler.crawl_every_page
