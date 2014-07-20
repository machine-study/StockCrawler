require 'require_all'
require_all '../model/*.rb'
require_all '../analysis/*.rb'
require 'logger'
require '../util/constant'

class FilterCollect
  def filter_combine_result(array)
    result =Hash.new
    array.each do |sub_hash|
      sub_hash.each do |k, v|
        if result.include? k
          result[k].current_quarterly_earnings =v.current_quarterly_earnings if v.current_quarterly_earnings!=nil
          result[k].annual_earnings_increase =v.annual_earnings_increase if v.annual_earnings_increase!=nil
        else
          result[k]=v
        end
      end

    end
    result.delete_if { |k, v| v==nil||v.current_quarterly_earnings==nil||v.annual_earnings_increase==nil }
    result
  end
  def FilterCollect.array_to_hash(array)
    hash = Hash.new
    array.each do|elem|
     hash[elem.code]=elem
    end
    hash
  end
end

STOCK_DAY_INFO_LOG=Logger.new(Constant::PROJECT_ROOT+'/logs/canslim_filter.log', 0, 10 * 1024 * 1024)
filter_collect = FilterCollect.new
canslim_filter = CanslimFilter.new
array = Array.new
a_hash = FilterCollect.array_to_hash(canslim_filter.a_filter(5))
c_hash = FilterCollect.array_to_hash(canslim_filter.c_filter("2014-03-31 00:00:00", "2013-03-31 00:00:00"))
array<<c_hash<<a_hash
result = filter_collect.filter_combine_result(array)
STOCK_DAY_INFO_LOG.info "these are filter combine result below:"
result.each_value do |value|
  STOCK_DAY_INFO_LOG.info value.code.to_s+" "+value.name.to_s+" "+value.industry.to_s+" "+value.annual_earnings_increase.to_s+" "+value.current_quarterly_earnings.to_s+"  ---"
end