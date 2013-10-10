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
      @manager = Celluloid::Actor[:manager]
    end

    def fetch
      messages = fetch_sqs_messages
      @manager.async.fetch_done(messages)
    end

  end
end