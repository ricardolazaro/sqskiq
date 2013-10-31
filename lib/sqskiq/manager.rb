require 'celluloid'
require 'celluloid/autostart'
require 'sqskiq/signal_handler'

module Sqskiq
  class Manager
    include Celluloid
    include Sqskiq::SignalHandler
    
    @empty_queue = false
    
    def initialize(empty_queue_throttle)
      @empty_queue_throttle = empty_queue_throttle
      subscribe_for_shutdown      
    end

    def bootstrap
      @fetcher = Celluloid::Actor[:fetcher]
      @batcher = Celluloid::Actor[:batcher]
      @deleter = Celluloid::Actor[:deleter]

      new_fetch(@fetcher.size)
    end

    def fetch_done(messages)
      @empty_queue = messages.empty?
      @batcher.async.process(messages) unless @shutting_down
    end

    def batch_done(messages)
      @deleter.async.delete(messages)
      new_fetch(1)
    end

    def new_fetch(num)
      after(throttle) do
        num.times { @fetcher.async.fetch unless @shutting_down }
      end
    end

    def running?
      not (@shutting_down and @deleter.busy_size == 0 and @batcher.busy_size == 0)
    end
    
    def throttle
      @empty_queue ? @empty_queue_throttle : 0
    end

  end
end