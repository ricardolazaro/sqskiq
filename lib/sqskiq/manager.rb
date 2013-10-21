require 'celluloid'
require 'celluloid/autostart'
require 'sqskiq/signal_handler'

module Sqskiq
  class Manager
    include Celluloid
    include Sqskiq::SignalHandler
    
    def initialize
      subscribe_for_shutdown
    end

    def bootstrap
      @fetcher = Celluloid::Actor[:fetcher]
      @batch_processor = Celluloid::Actor[:batch_processor]
      @deleter = Celluloid::Actor[:deleter]

      new_fetch(@fetcher.size)
    end

    def fetch_done(messages)
      @batch_processor.async.batch_process(messages) unless @shutting_down
    end

    def batch_process_done(messages)
      @deleter.async.delete(messages)
      new_fetch(1)
    end

    def new_fetch(num)
      num.times { @fetcher.async.fetch unless @shutting_down }
    end

    def running?
      not (@deleter.busy_size == 0 and @shutting_down and @batch_processor.busy_size == 0)
    end

  end
end