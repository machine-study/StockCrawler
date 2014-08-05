require 'require_all'
require_all '../model/*.rb'
require_all '../analysis/*.rb'
require 'logger'
require '../util/constant'
require '../crawler/investor_crawler'
require 'mechanize'

class FilterCollect
  def filter_combine_result(array)
    result =Hash.new
    array.each do |sub_hash|
      sub_hash.each do |k, v|
        if result.include? k
          result[k].current_quarterly_earnings =v.current_quarterly_earnings if v.current_quarterly_earnings!=nil
          result[k].annual_earnings_increase =v.annual_earnings_increase if v.annual_earnings_increase!=nil
          result[k].changepercent =v.changepercent if v.changepercent!=nil
          result[k].rs =v.rs if v.rs!=nil

          result[k].roe =v.roe if v.roe!=nil
          result[k].dar =v.dar if v.dar!=nil
        else
          result[k]=v
        end
      end

    end
    result.delete_if { |k, v| v==nil||v.current_quarterly_earnings==nil||v.annual_earnings_increase==nil||v.roe==nil||v.dar==nil||v.rs==nil }
    # result.delete_if { |k, v| v==nil||v.current_quarterly_earnings==nil||v.annual_earnings_increase==nil||v.roe==nil||v.dar==nil }
    result
  end

  def check_other_filter(hash)

  end

  def report_details()

  end

  def FilterCollect.array_to_hash(array)
    hash = Hash.new
    array.each do |elem|
      hash[elem.code]=elem
    end
    hash
  end
end

