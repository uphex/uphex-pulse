class ChangeSparklineAlgorithm < ActiveRecord::Migration
  def change
    #Delete all existing events
    Event.destroy_all
    #Set the analyzed_at to the far past, so the next update will pick up events
    Metric.all.each{|metric|
      metric[:analyzed_at]=DateTime.new
      metric.save!
    }
  end
end