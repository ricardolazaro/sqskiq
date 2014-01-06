require 'sqskiq/aws'

module Sqskiq
  class Deleter
    include Celluloid
    include Sqskiq::AWS

    def initialize(queue_name, configuration = {})
      init_queue(queue_name, configuration)
    end

    def delete(messages)
      delete_sqs_messages(messages) if not messages.empty?
    end
  end
end
