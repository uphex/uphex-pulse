class SparklineNormalizerProposed
  def normalize(sparkline)
    return [] if sparkline.empty?
    sparkline=sparkline.sort_by{|s| s[:index]}

    ranges(sparkline).map{|date|
      {:index=>date,:value=>interval_value(date,sparkline)}
    }
  end

  def last_observation(sparkline,date)
    sparkline.select{|observation| observation[:index]<date}.sort_by{|s| s[:index]}.last
  end

  def next_observation(sparkline,date)
    sparkline.select{|observation| observation[:index]>=date}.sort_by{|s| s[:index]}.first
  end

  def ranges(sparkline)
    minmax=sparkline.map{|val| val[:index].to_datetime}.minmax
    interval_start=minmax[0].beginning_of_day
    if minmax[0]>minmax[0].beginning_of_day
      interval_start=minmax[0].beginning_of_day+1.days
    end
    interval_end=minmax[1].beginning_of_day
    interval_start..interval_end-1.days
  end

  def interval_value(date,sparkline)

    def value_with_observations(date,observations_inside)
      sparkline_ranges=[]
      observations_inside.each_with_index{|observation,idx|
        if idx==0
          sparkline_ranges.push({:from=>date,:to=>observation[:index],:value=>observation[:value]})
        else
          sparkline_ranges.push({:from=>observations_inside[idx-1][:index],:to=>observation[:index],:value=>(observations_inside[idx-1][:value]+observation[:value])/2})
        end
      }
      sparkline_ranges.push({:from=>observations_inside.last[:index],:to=>date+1,:value=>observations_inside.last[:value]})
      ranges_inside=sparkline_ranges.reject{|val| val[:from]<date && val[:to]<date || val[:from]>date+1 && val[:to]>date+1}.map{|val| {:from=>val[:from]<date ? date : val[:from],:to=>val[:to]>date+1 ? date+1 : val[:to],:value=>val[:value]}}
      seconds_per_day=(date+1).to_time.to_i-date.to_time.to_i
      ranges_inside.map{|val|
        interval_seconds=(val[:to].to_time.to_i-val[:from].to_time.to_i)
        (interval_seconds.to_f)/seconds_per_day*val[:value]
      }.reduce(:+)
    end

    def value_without_observations(date,last_observation,next_observation)
      last_observation_distance=date.to_time.to_i-last_observation[:index].to_time.to_i
      next_observation_distance=next_observation[:index].to_time.to_i-(date+1).to_time.to_i

      (next_observation[:value]-last_observation[:value])*(last_observation_distance/(last_observation_distance.to_f+next_observation_distance.to_f))+last_observation[:value]
    end

    observations_inside=sparkline.select{|observation| observation[:index]>=date and observation[:index]<date+1}
    if observations_inside.empty?
      value_without_observations(date,last_observation(sparkline,date),next_observation(sparkline,date+1))
    else
      value_with_observations(date,observations_inside)
    end
  end
end