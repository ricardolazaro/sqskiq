class SampleWorker
  include Sqskiq::Worker

  sqskiq_options queue_name: :test, processors: 2

  def perform(message)
    sleep 0.5
    p "worker received #{message}"
  end

end