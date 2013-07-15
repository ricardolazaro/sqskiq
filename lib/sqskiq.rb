require "sqskiq/manager"
require 'sqskiq/fetch'
require 'sqskiq/process'
require 'sqskiq/delete'
require 'sqskiq/worker'
require 'sqskiq/batch_process'

module Sqskiq

  def self.bootstrap(options, worker_class)

    params = [ @aws_access_key_id, @aws_secret_access_key, options[:queue_name] ]

    Celluloid::Actor[:manager] = @manager = Manager.new
    Celluloid::Actor[:fetcher] = @fetcher = Fetcher.pool(:size => 2, :args => params)
    Celluloid::Actor[:processor] = @processor = Processor.pool(:size => 20, :args => worker_class)
    Celluloid::Actor[:batch_processor] = @batch_processor = BatchProcessor.pool(:size => 2)
    Celluloid::Actor[:deleter] = @deleter = Deleter.pool(:size => 2, :args => params)

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

end