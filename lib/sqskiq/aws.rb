require 'aws-sdk'

module Sqskiq
  module AWS

    def init_queue(aws_access_key_id, aws_secret_access_key, queue_name)
      sqs = ::AWS::SQS.new(:access_key_id => aws_access_key_id, :secret_access_key => aws_secret_access_key)
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