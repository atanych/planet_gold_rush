namespace :consumer do
  desc 'Subscribes to redis channel and sends batch-requests to an external server'
  task call: :environment do
    consumer = Consumer.new(Settings.event_list_key)
    consumer.perform
  end
end
