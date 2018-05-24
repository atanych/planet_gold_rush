class DispatchBatchJob < ApplicationJob
  queue_as :default

  def perform(batch_events)
    Faraday.post(Settings.external_service, events: batch_events)
  end
end
