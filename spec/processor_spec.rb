require 'spec_helper'

describe Sqskiq::Processor do
  let(:worker) { double }
  subject { described_class.new double(new: worker) }

  let(:message) { double(body: 'hello!') }

  context "Error handling" do
    before { worker.stub(:perform) { raise Exception.new "OMG!" } }

    it { expect(subject.process(message)[:success]).to be_false }
  end
end