require 'sqskiq/signal_handler'

module Sqskiq
  class Processor
    include Celluloid
    include Sqskiq::SignalHandler

    def initialize(worker_class)
      @worker_instance = worker_class.new
      subscribe_for_shutdown
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
    
  end
end
