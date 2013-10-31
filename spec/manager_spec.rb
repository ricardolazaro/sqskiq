require 'spec_helper'

describe Sqskiq::Manager do
  subject { Sqskiq::Manager.new(Random.rand(1..100)) }
  
  let(:deleter) { Object.new }
  let(:fetcher) { Object.new }
  let(:batcher) { Object.new }
  let(:shutting_down) { false }
  
  before do
    subject.instance_variable_set(:@fetcher, fetcher)
    subject.instance_variable_set(:@deleter, deleter)
    subject.instance_variable_set(:@batcher, batcher)
    subject.instance_variable_set(:@shutting_down, shutting_down)
  end

  describe '#running?' do
    context 'when the actor system is shutting down' do
      let(:shutting_down) { true }
     
      describe 'if deleter is not empty' do
        before { deleter.should_receive(:busy_size).and_return(1) }
 
        it { should be_running }
      end
     
      describe 'if batcher is not empty' do
        before do 
          deleter.should_receive(:busy_size).and_return(0) 
          batcher.should_receive(:busy_size).and_return(1) 
        end

        it { should be_running }
      end
     
      describe 'if batcher and deleter are empties' do
        before do 
          deleter.should_receive(:busy_size).and_return(0) 
          batcher.should_receive(:busy_size).and_return(0) 
        end

        it { should_not be_running }
      end    
    end
    
    context 'when the actor system is not shutting down' do
      
      describe 'even if batcher and deleter are empties' do
        before do 
          deleter.stub(:busy_size).and_return(0) 
          batcher.stub(:busy_size).and_return(0) 
        end

        it { should be_running }
      end
      
    end
  end
  
  describe '#new_fetch' do
    before do
      subject.instance_variable_set(:@empty_queue, empty)
      subject.instance_variable_set(:@empty_queue_throttle, 10)
    end
    
    context 'if queue is not empty' do
      let(:empty) { false }
      
      it 'applies a throttle of 0 seconds' do
        Sqskiq::Manager.any_instance.should_receive(:after).with(0)
        subject.new_fetch(1)
      end
    end
    
    context 'if queue is empty' do
      let(:empty) { true }
      
      it 'applies a throttle of empty_queue_throttle seconds' do
        Sqskiq::Manager.any_instance.should_receive(:after).with(10)
        subject.new_fetch(1)
      end
    end
  end
  
  describe '#fetch_done' do
    
    before { subject.instance_variable_set(:@empty_queue, empty) }
    
    context 'when at least one message has been received' do
      let(:messages) { ['someMessage'] }
      let(:empty) { true } 
      
      it 'sets @empty_queue to false and process the messages' do
        batcher.should_receive(:async).and_return(batcher)
        batcher.should_receive(:process).with(messages)
        subject.fetch_done(messages)
        subject.instance_variable_get(:@empty_queue).should be_false
      end
    end
    
    context 'when no messages are received' do
      let(:messages) { [] }
      let(:empty) { false } 

      it 'sets @empty_queue to true and does not process the messages' do
        batcher.should_receive(:async).and_return(batcher)
        batcher.should_receive(:process).with(messages)
        subject.fetch_done(messages)
        subject.instance_variable_get(:@empty_queue).should be_true
      end
    end    
  end
  
end