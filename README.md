Sqskiq
======

High performance, [Sidekiq](https://github.com/mperham/sidekiq).-like Amazon SQS messages consumer.
Currently only supports Rails 3.x.

SQS is complete message solution powered by Amazon, including monitoring, alarms, redundancy, etc. 
Due to its particularities, we decide to build a message consumer from scratch, to better handle costs, latency and others.

Getting Start
-------------

1. Add sqskiq to your Gemfile:

  ```ruby
  gem 'sqskiq'
  ```

2. Add an initializer `config/initializers/sqskiq.rb` with:

  ```ruby
  Sqskiq.configure do |config|
    config.aws_access_key_id = 'AWS_ACCESS_KEY_ID'
    config.aws_secret_access_key = 'AWS_SECRET_ACCESS_KEY'
  end
  ```

3. Add a worker in `app/workers` to process messages asynchronously:

  ```ruby
  class HardWorker
    include Sqskiq::Worker

    sqskiq_options queue_name: :queue_test

    def perform(message)
      # do something
    end
  end
  ```

  You can configure the number of worker using the param 'processors'. Ex: sqskiq_options queue_name: :queue_test, processors: 30
  OBS: Currently, the min number of processors is 2 and the default is 20. Any unacceptable value will end up using the default. 	

4. Start sqskiq and consumes the queue:

  ```ruby
  rails runner HardWorker.run
  ```

Deploy
------

Use a procfile (like heroku does) to start your workers. In your Procfile, add:

  ```
  queue_test: rails runner 'HardWorker.run'
  ```

Tips and Limitations
--------------------

* Currently, the min number of workers is 2
* If your worker uses Mongoid, ActiveRecord, etc... make sure to disable data caches (at least clean the data after each execution) or your workers will explode.
* We perform automatic retry if the execution raises exception
* if the execution does not rise exception, we assume we can remove the message 
* Be aware of the costs of using SQS, even they having a free tier for the service





