require "sqskiq/manager"
require 'sqskiq/fetch'
require 'sqskiq/process'
require 'sqskiq/delete'
require 'sqskiq/worker'
require 'sqskiq/batch_process'

module Sqskiq
  DEFAULT_POOL_SIZE = {
      fetcher: 2,
      processor: 20,
      batch_processor: 2,
      deleter: 2
  }

  def self.bootstrap(options, worker_class)

    params = [ @aws_access_key_id, @aws_secret_access_key, options[:queue_name] ]

    Celluloid::Actor[:manager] = @manager = Manager.new
    Celluloid::Actor[:fetcher] = @fetcher = Fetcher.pool(:size => pools[:fetcher], :args => params)
    Celluloid::Actor[:processor] = @processor = Processor.pool(:size => pools[:processor], :args => worker_class)
    Celluloid::Actor[:batch_processor] = @batch_processor = BatchProcessor.pool(:size => pools[:batch_processor])
    Celluloid::Actor[:deleter] = @deleter = Deleter.pool(:size => pools[:deleter], :args => params)

    p "pid = #{Process.pid}"

    trap('SIGTERM') do
      @manager.publish('SIGTERM')
    end

    trap('TERM') do
      @manager.publish('TERM')
    end

    trap('SIGINT') do
      @manager.publish('SIGINT')
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

  def self.pools
    @pools ||= DEFAULT_POOL_SIZE
  end

  def self.pools=(params)
    @pools = pools.merge(params)
  end

  def self.logger
    @logger ||= ::Logger.new($stdout)
  end
end