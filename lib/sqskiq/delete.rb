require 'celluloid'
require 'celluloid/autostart'
require 'sqskiq/aws'

module Sqskiq
  class Deleter
    include Celluloid
    include Celluloid::Notifications
    include Sqskiq::AWS

    def initialize(aws_access_key_id, aws_secret_access_key, queue_name)
      init_queue(aws_access_key_id, aws_secret_access_key, queue_name)
    end

    def delete(messages)
      delete_sqs_messages(messages) if not messages.empty?
    end
  end
end