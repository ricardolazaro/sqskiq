require 'spec_helper'

describe Sqskiq::Manager do
  let(:deleter) { Object.new }
  let(:fetcher) { Object.new }
  let(:batch_processor) { Object.new }
  let(:shutting_down) { false }
  
  before do
    subject.instance_variable_set(:@fetcher, fetcher)
    subject.instance_variable_set(:@deleter, deleter)
    subject.instance_variable_set(:@batch_processor, batch_processor)
    subject.instance_variable_set(:@shutting_down, shutting_down)
  end

  describe '#running?' do
     
    context 'when the actor system is shutting down' do
     let(:shutting_down) { true }
     
     describe 'if deleter is not empty' do
       before { deleter.should_receive(:busy_size).and_return(1) }
       
       it 'returns true' do
         subject.running?.should be_true
       end
     end
     
     describe 'if batch_processor is not empty' do
       before do 
         deleter.should_receive(:busy_size).and_return(0) 
         batch_processor.should_receive(:busy_size).and_return(1) 
       end

       it 'returns true' do
         subject.running?.should be_true
       end
     end
     
     describe 'if batch_processor and deleter are empties' do
        before do 
          deleter.should_receive(:busy_size).and_return(0) 
          batch_processor.should_receive(:busy_size).and_return(0) 
        end

        it 'returns false' do
          subject.running?.should be_false
        end
      end
       
    end
    
    context 'when the actor system is not shutting down' do
      
      describe 'even if batch_processor and deleter are empties' do
        before do 
          deleter.stub(:busy_size).and_return(0) 
          batch_processor.stub(:busy_size).and_return(0) 
        end

        it 'returns true' do
          subject.running?.should be_true
        end
      end
      
    end
  end

end