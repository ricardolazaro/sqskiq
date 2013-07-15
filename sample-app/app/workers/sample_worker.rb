class SampleWorker
  include Sqskiq::Worker

  sqskiq_options queue_name: :test

  def perform(message)
    p "worker received #{message}"
  end

end