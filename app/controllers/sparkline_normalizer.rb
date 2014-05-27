class SparklineNormalizer
  def normalize(sparkline)
    sparkline_ranges=[]
    for i in 0..sparkline.size-2
      sparkline_ranges << {:from=>sparkline[i][:index],:to=>sparkline[i+1][:index],:value=>(sparkline[i][:value]+sparkline[i+1][:value])/2}
    end
    minmax=sparkline.map{|val| val[:index].to_datetime}.minmax
    interval_start=minmax[0].beginning_of_day
    if minmax[0]>minmax[0].beginning_of_day
      interval_start=minmax[0].beginning_of_day+1.days
    end
    interval_end=minmax[1].beginning_of_day
    range=interval_start..interval_end-1.days
    range.map{|date|
      ranges_inside=sparkline_ranges.reject{|val| val[:from]<date && val[:to]<date || val[:from]>date+1 && val[:to]>date+1}.map{|val| {:from=>val[:from]<date ? date : val[:from],:to=>val[:to]>date+1 ? date+1 : val[:to],:value=>val[:value]}}
      seconds_per_day=(date+1).to_time.to_i-date.to_time.to_i
      sum=ranges_inside.map{|val|
        interval_seconds=(val[:to].to_time.to_i-val[:from].to_time.to_i)
        (interval_seconds.to_f)/seconds_per_day*val[:value]
      }.reduce(:+)
      {:index=>date,:value=>sum}
    }

  end
end