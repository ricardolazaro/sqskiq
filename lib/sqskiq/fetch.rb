require 'sqskiq/aws'

module Sqskiq
  class Fetcher
    include Celluloid
    include Sqskiq::AWS

    def initialize(queue_name, configuration = {})
      init_queue(queue_name, configuration)
      @manager = Celluloid::Actor[:manager]
    end

    def fetch
      messages = fetch_sqs_messages
      @manager.async.fetch_done(messages)
    end

  end
end
