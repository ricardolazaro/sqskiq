Gem::Specification.new do |s|
  s.name        = 'sqskiq'
  s.version     = '0.0.10'
  s.date        = '2013-11-01'
  s.summary     = "sqskiq"
  s.description = "Sidekiq-like Ruby background processing using Amazon SQS"
  s.authors     = ["Ricardo Lazaro de Oliveira", "Maxim Filippovich"]
  s.email       = ['ri.vanlazar@gmail.com', 'fatumka@gmail.com']
  s.license     = 'LGPL-3.0'
  s.files       = ["lib/sqskiq.rb", "lib/sqskiq/manager.rb", "lib/sqskiq/fetch.rb", "lib/sqskiq/process.rb", "lib/sqskiq/delete.rb", "lib/sqskiq/worker.rb", "lib/sqskiq/batch_process.rb", "lib/sqskiq/aws.rb", "lib/sqskiq/signal_handler.rb"]
  s.test_files  = Dir["spec/**/*"]
  s.require_paths = ["lib"]
  s.homepage    = 'https://github.com/ricardolazaro/sqskiq'

  s.add_dependency "celluloid"
  s.add_dependency "aws-sdk", "~> 1"
  s.add_dependency "activesupport"
  s.add_dependency "json"

  s.add_development_dependency "rspec"
end
