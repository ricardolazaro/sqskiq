require 'celluloid'
require 'celluloid/autostart'
require 'sqskiq/aws'

module Sqskiq
  class Fetcher
    include Celluloid
    include Celluloid::Notifications
    include Sqskiq::AWS

    def initialize(aws_access_key_id, aws_secret_access_key, queue_name)
      init_queue(aws_access_key_id, aws_secret_access_key, queue_name)
      subscribe_interrupt

      @manager = Celluloid::Actor[:manager]
    end

    def fetch
      messages = fetch_sqs_messages
      @manager.async.fetch_done(messages)
    end

    def subscribe_interrupt
      subscribe('SIGINT', :interrupt)
      subscribe('SIGTERM', :interrupt)
      subscribe('TERM', :interrupt)
    end

    def interrupt(signal)
      self.terminate
    end

  end
end