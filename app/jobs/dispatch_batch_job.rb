class DispatchBatchJob < ApplicationJob
  queue_as :default

  def perform(batch_events)
    conn = Faraday.new(url: Settings.external_service)
    conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(batch_events)
    end
  end
end
