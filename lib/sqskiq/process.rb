require 'celluloid'
require 'celluloid/autostart'

module Sqskiq
  class Processor
    include Celluloid
    include Celluloid::Notifications

    def initialize(worker_class)
      @worker_instance = worker_class.new

      subscribe_interrupt
    end

    def process(message)
      result = true
      begin
        @worker_instance.perform(message)
      rescue Exception => e
        result = false
      end
      { :success => result, :message => message }
    end

    def subscribe_interrupt
      subscribe('SIGINT', :interrupt)
      subscribe('TERM', :interrupt)
      subscribe('SIGTERM', :interrupt)
    end

    def interrupt(signal)
      self.terminate
    end

  end
end