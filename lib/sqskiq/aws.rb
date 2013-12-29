require 'aws-sdk'

module Sqskiq
  module AWS

    def init_queue(queue_name, configuration = {})
      p configuration.inspect

      sqs = ::AWS::SQS.new(configuration)
      @queue = sqs.queues.named(queue_name.to_s)
    end

    def fetch_sqs_messages
      @queue.receive_message(:limit => 10, :attributes => [:receive_count])
    end

    def delete_sqs_messages(messages)
      @queue.batch_delete(messages)
    end

  end
end
