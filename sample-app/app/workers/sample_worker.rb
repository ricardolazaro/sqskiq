class SampleWorker
  include Sqskiq::Worker

  sqskiq_options queue_name: :test, processors: 200, empty_queue_throttle: 20

  def perform(message)
    p "worker received #{message}"
  end
end
