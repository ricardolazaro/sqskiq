module Sqskiq
  module SignalHandler
    include Celluloid
    include Celluloid::Notifications

    @shutting_down = false

    def subscribe_for_shutdown
      subscribe('SIGINT', :shutting_down)
      subscribe('TERM', :shutting_down)
      subscribe('SIGTERM', :shutting_down)
    end

    def shutting_down(signal)
      @shutting_down = true
    end
  end
end