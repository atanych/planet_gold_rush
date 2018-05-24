namespace :benchmark do
  desc 'redis llen vs redis lrange'
  task llen_vs_lrange: :environment do
    (1..400).map { Redis.current.rpush('xxx', rand) }
    Benchmark.bmbm do |x|
      x.report('lrange: ') { Redis.current.lrange('xxx', 0, 9) }
      x.report('llen: ') { Redis.current.llen('xxx') }
    end
    Redis.current.del('xxx')
  end

  desc 'consumer#handle_iteration'
  task handle_iteration: :environment do
    requests = 1_000
    (1..requests).map { Redis.current.rpush('xxx', rand) }

    consumer = Consumer.new('xxx')
    start = Time.now
    (1..(requests/Settings.batch_size)).map { consumer.handle_iteration }
    puts '*** consumer#handle_iteration ***'
    puts "Handled #{requests} requests"
    puts "#{Time.now - start}s"
    Redis.current.del('xxx')
  end
end
