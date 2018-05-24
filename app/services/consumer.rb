class Consumer
  attr_accessor :last_dispatched_at, :redis_key

  TIMEOUT = 0.01

  def initialize(redis_key)
    @last_dispatched_at = Time.now
    @redis_key = redis_key
  end

  def perform
    loop do
      handle_iteration
    end
  end

  def handle_iteration
    batch_events = redis.lrange(redis_key, 0, 10)
    if need_backoff?(batch_events)
      dispatch(batch_events)
      return
    end

    if batch_ready?(batch_events)
      dispatch(batch_events)
    end
    sleep TIMEOUT
  end

  private

  def dispatch(batch_events)
    redis.ltrim(redis_key, Settings.batch_size, -1)
    DispatchBatchJob.perform_later(batch_events)
    @last_dispatched_at = Time.now
  end

  def redis
    Redis.current
  end

  def batch_ready?(batch_events)
    batch_events.size >= Settings.batch_size
  end

  def need_backoff?(batch_events)
    batch_events.present? && Time.now - last_dispatched_at >= Settings.backoff_duration
  end
end
