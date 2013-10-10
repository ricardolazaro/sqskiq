require 'celluloid'
require 'celluloid/autostart'

module Sqskiq
  class Processor
    include Celluloid
    include Celluloid::Notifications

    def initialize(worker_class)
      @worker_instance = worker_class.new
      @shutting_down = false
      subscribe_shutting_down
    end

    def process(message)
      return  { :success => false, :message => message } if @shutting_down

      result = true
      begin
        @worker_instance.perform(message)
      rescue Exception => e
        result = false
      end
      return { :success => result, :message => message }
    end

    def shutting_down(signal)
      @shutting_down = true
    end

    def subscribe_shutting_down
      subscribe('SIGINT', :shutting_down)
      subscribe('TERM', :shutting_down)
      subscribe('SIGTERM', :shutting_down)
    end
  end
end