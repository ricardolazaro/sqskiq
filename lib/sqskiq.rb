require "sqskiq/manager"
require 'sqskiq/fetch'
require 'sqskiq/process'
require 'sqskiq/delete'
require 'sqskiq/worker'
require 'sqskiq/batch_process'

module Sqskiq

  def self.bootstrap(options, worker_class)
    params = [ @aws_access_key_id, @aws_secret_access_key, options[:queue_name] ]
    
    configured_pool_sizes = pool_sizes(options)
    
    Celluloid::Actor[:manager] = @manager = Manager.new
    Celluloid::Actor[:fetcher] = @fetcher = Fetcher.pool(:size => configured_pool_sizes[:num_fetchers], :args => params)
    Celluloid::Actor[:processor] = @processor = Processor.pool(:size => configured_pool_sizes[:num_workers], :args => worker_class)
    Celluloid::Actor[:batch_processor] = @batch_processor = BatchProcessor.pool(:size => configured_pool_sizes[:num_batches])
    Celluloid::Actor[:deleter] = @deleter = Deleter.pool(:size => configured_pool_sizes[:num_deleters], :args => params)

    trap('SIGTERM') do
      @manager.publish('SIGTERM')
      @batch_processor.publish('SIGTERM')
      @processor.publish('SIGTERM')
    end

    trap('TERM') do
      @manager.publish('TERM')
      @batch_processor.publish('TERM')
      @processor.publish('TERM')
    end

    trap('SIGINT') do
      @manager.publish('SIGINT')
      @batch_processor.publish('SIGINT')
      @processor.publish('SIGINT')
    end

    @manager.bootstrap
    while @manager.running? do
      sleep 2
    end

    @fetcher.__shutdown__
    @batch_processor.__shutdown__
    @processor.__shutdown__
    @deleter.__shutdown__

    @manager.terminate
  end
  
  def self.pool_sizes(options)
    # for now, min processors should be 2
    num_workers = (options[:processors].nil? || options[:processors].to_i < 2)? 20 : options[:processors]
    
    # each fetch brings up to 10 messages to process.
    # the number of fetchers is the min number able to keep all
    # workers handling messages
    # TODO: acctualy the min number must be greater than 2 because we are using
    # celluloid pool, but that will be changed!
    num_fetchers = num_workers / 10
    num_fetchers = num_fetchers + 1 if num_workers % 10 > 0
    num_fetchers = 2 if num_fetchers < 2
    
    num_deleters = num_batches = num_fetchers
    
    { num_workers: num_workers, num_fetchers: num_fetchers, num_batches: num_batches, num_deleters: num_deleters }
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