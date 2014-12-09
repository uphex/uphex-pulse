web: rackup
worker: env REDIS_URL=redis://$REDIS_ADDRESS bundle exec rake environment resque:work QUEUE=*
clock:  env REDIS_URL=redis://$REDIS_ADDRESS bundle exec rake environment resque:scheduler