class SparklineNormalizerProposed

  def initialize(sparkline)
    @sparkline=sparkline.sort_by { |s| s[:index] }
  end

  def normalized
    return [] if @sparkline.empty?

    ranges.map { |date|
      {:index => date, :value => interval_value(date)}
    }
  end

  def last_observation_before(date)
    @sparkline.select { |observation| observation[:index]<date }.sort_by { |s| s[:index] }.last
  end

  def next_observation_after(date)
    @sparkline.select { |observation| observation[:index]>=date }.sort_by { |s| s[:index] }.first
  end

  def ranges
    min_observation_time,max_observation_time = @sparkline.map { |val| val[:index].to_datetime }.minmax
    interval_start=begin
      if min_observation_time > min_observation_time.beginning_of_day
        min_observation_time.beginning_of_day+1.day
      else
        min_observation_time.beginning_of_day
      end
    end
    interval_end = max_observation_time.beginning_of_day
    interval_start..interval_end-1.day
  end

  def range_outside?(range, from, to)
    (range[:from] < from && range[:to] < from) or (range[:from] > to && range[:to] > to)
  end

  def trim_range(range, from, to)
    {:from => [range[:from],from].max, :to => [range[:to],to].min, :value => range[:value]}
  end

  def average_value(observations)
    observations.map{ |observation| observation[:value]}.reduce(:+) / observations.size
  end

  def interval_value(date)

    def value_with_observations(date, observations_inside)
      sparkline_ranges = observations_inside.map.with_index { |observation, idx|
        if idx == 0
          {:from => date, :to => observation[:index], :value => observation[:value]}
        else
          previous_observation = observations_inside[idx-1]
          {:from => previous_observation[:index], :to => observation[:index], :value => average_value([previous_observation, observation])}
        end
      }
      sparkline_ranges.push({:from => observations_inside.last[:index], :to => date+1, :value => observations_inside.last[:value]})
      ranges_inside = sparkline_ranges
        .reject { |range| range_outside?(range, date, date+1) }
        .map { |range| trim_range(range, date, date+1) }
      seconds_per_day = (date+1).to_time.to_i - date.to_time.to_i
      ranges_inside.map { |val|
        interval_seconds = val[:to].to_time.to_i - val[:from].to_time.to_i
        (interval_seconds.to_f) / seconds_per_day * val[:value]
      }.reduce(:+)
    end

    def value_without_observations(date, last_observation, next_observation)
      last_observation_distance = date.to_time.to_i - last_observation[:index].to_time.to_i
      next_observation_distance = next_observation[:index].to_time.to_i - (date+1).to_time.to_i

      relative_position = (last_observation_distance / (last_observation_distance.to_f + next_observation_distance.to_f))
      next_value = next_observation[:value]
      last_value = last_observation[:value]

      (next_value - last_value) * relative_position + last_value
    end

    observations_inside = @sparkline.select { |observation| observation[:index] >= date and observation[:index] < (date+1) }
    if observations_inside.empty?
      value_without_observations(date, last_observation_before(date), next_observation_after(date+1))
    else
      value_with_observations(date, observations_inside)
    end
  end
end