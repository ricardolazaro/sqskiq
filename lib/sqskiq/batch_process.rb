require 'celluloid'
require 'celluloid/autostart'

module Sqskiq
  class BatchProcessor
    include Celluloid
    include Celluloid::Notifications

    def initialize
      @manager = Celluloid::Actor[:manager]
      @processor = Celluloid::Actor[:processor]
    end

    def batch_process(messages)
      p "processing #{messages.size} messages"

      process_result = []
      messages.each do |message|
        process_result << @processor.future.process(message)
      end

      success_messages = []
      process_result.each do |result|
        value = result.value
        if value[:success]
          success_messages << value[:message]
        end
      end

      @manager.async.batch_process_done(success_messages)
    end
  end
end