class SampleWorker
  include Sqskiq::Worker

  sqskiq_options queue_name: :test, processors: 2

  def perform(message)
    p "worker received #{message}"
  end

end