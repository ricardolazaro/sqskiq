require "sqskiq/manager"
require 'sqskiq/fetch'
require 'sqskiq/process'
require 'sqskiq/delete'
require 'sqskiq/worker'
require 'sqskiq/batch_process'

module Sqskiq

  def self.bootstrap(options, worker_class)

    params = [ @aws_access_key_id, @aws_secret_access_key, options[:queue_name] ]
    num_fetchers = options[:fetchers]  || 2
    num_workers  = options[:processors] || 10
    num_deleters = num_batches = num_fetchers

    Celluloid::Actor[:manager] = @manager = Manager.new
    Celluloid::Actor[:fetcher] = @fetcher = Fetcher.pool(:size => num_fetchers, :args => params)
    Celluloid::Actor[:processor] = @processor = Processor.pool(:size => num_workers, :args => worker_class)
    Celluloid::Actor[:batch_processor] = @batch_processor = BatchProcessor.pool(:size => num_batches)
    Celluloid::Actor[:deleter] = @deleter = Deleter.pool(:size => num_deleters, :args => params)

    p "pid = #{Process.pid}"

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