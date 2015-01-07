namespace :uphex do
  task :export_db, [:file_name] => :environment do |t, args|
    args.with_defaults(:file_name => 'export.json')

    result= Hash[[User, Role, Account, Organization, Portfolio, Provider, Metric].map{|object|
      [object.to_s, object.send(:all)]
    }]

    result['Observation']=Metric.select{|metric|
      %w(postImpressionsPaid postImpressionsFanPaid postVideoCompleteViewsPaid postVideoViewsPaid followers hard_bounces soft_bounces unsubscribes forwards unique_opens unique_clicks).include? metric['name']
    }.map{|metric|
      metric.observations
    }.flatten

    puts "Exporting data to: #{args[:file_name]}"

    IO.write(args[:file_name], result.to_json)

    puts "Stats:"

    result.each do |key, array|
      puts "#{key}: #{array.length}"
    end
  end
end