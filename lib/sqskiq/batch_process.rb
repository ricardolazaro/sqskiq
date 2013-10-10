require 'celluloid'
require 'celluloid/autostart'

module Sqskiq
  class BatchProcessor
    include Celluloid
    include Celluloid::Notifications

    def initialize
      @manager = Celluloid::Actor[:manager]
      @processor = Celluloid::Actor[:processor]
      @shutting_down = false
      subscribe_shutting_down
    end

    def batch_process(messages)
      p "processing #{messages.size} messages"

      process_result = []
      messages.each do |message|
        process_result << @processor.future.process(message)
      end

      success_messages = []
      process_result.each do |result|

        unless @shutting_down
          value = result.value
          if value[:success]
            success_messages << value[:message]
          end
        end
      end

      @manager.async.batch_process_done(success_messages)
    end

    def shutting_down(signal)
      @shutting_down = true
    end

    def subscribe_shutting_down
      subscribe('SIGINT', :shutting_down)
      subscribe('TERM', :shutting_down)
      subscribe('SIGTERM', :shutting_down)
    end
  end
end