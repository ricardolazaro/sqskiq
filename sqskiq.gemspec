Gem::Specification.new do |s|
  s.name        = 'sqskiq'
  s.version     = '0.0.2'
  s.date        = '2013-06-01'
  s.summary     = "sqskiq"
  s.description = "Sidekiq-like Ruby background processing using Amazon SQS"
  s.authors     = ["Ricardo Lazaro de Oliveira"]
  s.email       = 'ri.vanlazar@gmail.com'
  s.files       = ["lib/sqskiq.rb", "lib/sqskiq/manager.rb", "lib/sqskiq/fetch.rb", "lib/sqskiq/process.rb", "lib/sqskiq/delete.rb", "lib/sqskiq/worker.rb", "lib/sqskiq/batch_process.rb", "lib/sqskiq/aws.rb"]
  s.test_files  = Dir["spec/**/*"]
  s.require_paths = ["lib"]
  s.homepage    = 'https://github.com/ricardolazaro/sqskiq'

  s.add_dependency "celluloid", "~> 0.14.1"
  s.add_dependency "aws-sdk", "~> 1.9.1"
  s.add_dependency "activesupport"
  s.add_development_dependency "rspec"
end
