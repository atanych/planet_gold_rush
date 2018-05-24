require 'rails_helper'

RSpec.describe Consumer do
  describe '#handle_iteration' do

    context 'when I have prepared batch' do
      before do
        (1..20).map { Redis.current.rpush('xxx', 'event1') }
      end
      it 'I should sent it to external service' do
        consumer = Consumer.new('xxx')
        expect(DispatchBatchJob).to receive(:perform_later).with(['event1', 'event1', 'event1', 'event1', 'event1', 'event1', 'event1', 'event1', 'event1', 'event1', 'event1'])
        consumer.handle_iteration
        Redis.current.del('xxx')
      end
    end

    context 'when I have some events in the batch' do
      before do
        (1..4).map { Redis.current.rpush('xxx', 'event1') }
      end
      context 'and I did not send any batch last 1 minute' do
        before do
          @consumer = Consumer.new('xxx')
          @consumer.last_dispatched_at = 1.minute.ago
        end
        it 'I should sent all events in the batch to external service' do
          expect(DispatchBatchJob).to receive(:perform_later).with(['event1', 'event1', 'event1', 'event1'])
          @consumer.handle_iteration
          Redis.current.del('xxx')
        end
      end
    end
  end
end
