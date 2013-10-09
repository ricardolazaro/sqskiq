require 'celluloid'
require 'celluloid/autostart'

module Sqskiq
  class Processor
    include Celluloid
    include Celluloid::Notifications

    def initialize(worker_class)
      @worker_instance = worker_class.new
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
  end
end