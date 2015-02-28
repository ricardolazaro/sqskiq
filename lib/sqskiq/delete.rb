require 'sqskiq/aws'
require 'sqskiq/signal_handler'

module Sqskiq
  class Deleter
    include Celluloid
    include Sqskiq::AWS
    include Sqskiq::SignalHandler

    def initialize(queue_name, configuration = {})
      init_queue(queue_name, configuration)
      subscribe_for_shutdown
    end

    def delete(messages)
      return if @shutting_down

      delete_sqs_messages(messages) if not messages.empty?
    end
  end
end
