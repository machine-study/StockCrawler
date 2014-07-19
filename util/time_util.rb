class TimeUtil
  def TimeUtil.get_last_n_year_end(n)
    last_n_year_end = Time.new(Time.now.year-n, 12, 31)
  end
end
puts TimeUtil.get_last_n_year_end(5)


