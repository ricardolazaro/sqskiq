require 'spec_helper'

class DummyWorker
  include Sqskiq::Worker

  sqskiq_options queue_name: :test, retry: 2

  def perform(message)
    p "worker received #{message.body}"
    sleep 2
  end
end

describe Sqskiq::Worker do
  subject { DummyWorker }

  context "Just run" do
    before do
      mock_queue = double(receive_message: [double(body:'omg!')], batch_delete: nil)
      ::AWS::SQS.stub(:new) { double(queues: double(named: mock_queue)) }
    end

    it "just consumes" do
      puts "Work in progress. Hit Ctrl+C to stop. To do: implement another way to stop"
      subject.run
    end
  end
end