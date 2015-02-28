require 'sqskiq/aws'
require 'sqskiq/signal_handler'

module Sqskiq
  class Fetcher
    include Celluloid
    include Sqskiq::AWS
    include Sqskiq::SignalHandler

    def initialize(queue_name, configuration = {})
      init_queue(queue_name, configuration)
      @manager = Celluloid::Actor[:manager]

      subscribe_for_shutdown
    end

    def fetch
      return if @shutting_down

      messages = fetch_sqs_messages
      @manager.async.fetch_done(messages)
    end
  end
end
