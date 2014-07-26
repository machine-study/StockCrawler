class TimeUtil
  def TimeUtil.get_last_n_year_end(n)
    last_n_year_end = Time.new(Time.now.year-n, 12, 31)
  end
  def TimeUtil.get_recent_day_slot
    now = Time.now
    sd = Time.new(now.year,now.month,now.day)
    time_begin = sd-(sd.wday-5)*60*60*24
    time_end = time_begin+60*60*24
    [time_begin.to_s,time_end.to_s]
  end
end


