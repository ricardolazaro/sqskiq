require "sqskiq/manager"
require 'sqskiq/fetch'
require 'sqskiq/process'
require 'sqskiq/delete'
require 'sqskiq/worker'
require 'sqskiq/batch_process'

module Sqskiq

  ## 
  # Configure and start actor system
  def self.bootstrap(worker_config, worker_class)
    
    config = valid_config_from(worker_config)
    aws_params = [ @aws_access_key_id, @aws_secret_access_key, config[:queue_name] ]
    
    Celluloid::Actor[:manager]   = @manager   = Manager.new
    Celluloid::Actor[:fetcher]   = @fetcher   = Fetcher.pool(:size => config[:num_fetchers], :args => aws_params)
    Celluloid::Actor[:deleter]   = @deleter   = Deleter.pool(:size => config[:num_deleters], :args => aws_params)
    Celluloid::Actor[:processor] = @processor = Processor.pool(:size => config[:num_workers], :args => worker_class)
    Celluloid::Actor[:batcher]   = @batcher   = BatchProcessor.pool(:size => config[:num_batches])
    
    configure_signal_listeners

    @manager.bootstrap
    while @manager.running? do
      sleep 2
    end

    @manager.terminate
  end
  
  # Subscribe actors to receive system signals
  # Each actor when receives a signal should execute
  # appropriate code to exit cleanly
  def self.configure_signal_listeners
    ['SIGTERM', 'TERM', 'SIGINT'].each do |signal|
      trap(signal) do
        @manager.publish('SIGTERM')
        @batcher.publish('SIGTERM')
        @processor.publish('SIGTERM')
      end
    end
  end
  
  ##
  # check the provided configuration
  # and add the defaults when not specified
  def self.valid_config_from(worker_config)
    num_workers = (worker_config[:processors].nil? || worker_config[:processors].to_i < 2)? 20 : worker_config[:processors]
    
    # messy code due to celluloid pool constraint of 2 as min pool size: see spec for better understanding
    num_fetchers = num_workers / 10
    num_fetchers = num_fetchers + 1 if num_workers % 10 > 0
    num_fetchers = 2 if num_fetchers < 2
    num_deleters = num_batches = num_fetchers
        
    { 
      num_workers: num_workers, 
      num_fetchers: num_fetchers, 
      num_batches: num_batches, 
      num_deleters: num_deleters,
      queue_name: worker_config[:queue_name]
    }
  end
  
  def self.configure
    yield self
  end

  def self.aws_access_key_id=(value)
    @aws_access_key_id = value
  end

  def self.aws_secret_access_key=(value)
    @aws_secret_access_key = value
  end

end