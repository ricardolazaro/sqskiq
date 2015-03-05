require 'sqskiq/signal_handler'

module Sqskiq
  class BatchProcessor
    include Celluloid
    include Sqskiq::SignalHandler

    def initialize
      @manager = Celluloid::Actor[:manager]
      @processor = Celluloid::Actor[:processor]

      subscribe_for_shutdown
    end

    def process(messages)
      return if @shutting_down

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

      @manager.async.batch_done(success_messages)
    end
  end
end
