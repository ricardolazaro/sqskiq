Sqskiq
======

High performance, [Sidekiq](https://github.com/mperham/sidekiq)-like Amazon SQS messages consumer.
Currently only supports Rails 3.x.

SQS is complete message solution powered by Amazon, including monitoring, alarms, redundancy, etc. 
Due to its particularities, we decided to build a message consumer from scratch, to better handle costs, latency and others.

Getting Start
-------------

1.  Add sqskiq to your Gemfile:

  ```ruby
  gem 'sqskiq'
  ```
2.  Add an initializer `config/initializers/sqskiq.rb` with:


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
  OBS1: The message received by this worker is an instance of [AWS::SQS::ReceivedMessage](http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/SQS/ReceivedMessage.html)

  OBS2: You can configure the parallelism using the param 'processors'. Ex: 
  `sqskiq_options queue_name: :queue_test, processors: 30`
  
  OBS3: Currently, the min number of processors is 2 and the default is 20. Any unacceptable value will end up using the default. 	

4. Start Sqskiq and consume the queue:

  ```ruby
    rails runner HardWorker.run
  ```

Deploy
------

Use a Procfile (like Heroku does) to start your workers. In your Procfile, add:

```
  queue_test: rails runner 'HardWorker.run'
```

Tips and Limitations
--------------------

* Currently, the minimum number of workers is 2
* If your worker uses Mongoid, ActiveRecord, etc... make sure to disable data caches (or at least clean the data after each execution), otherwise your workers will explode.
* Workers will automatically retry a job if the execution raises an exception
* If the execution does not raise an exception, workers assume the execution ran cleanly and will remove the message from queue 
* Be aware of the costs of using SQS, even while under the service's free tier

### Future and TODO's

* Implement a better retry policy (today the message will be retried forever)
* Implement policies to reduce/eliminate costs for queues with low throughput
* User can configure only one processor
* Client side to send messages to SQS, handling batches
* Better database integration with automatic cache clean
* Load Celluloid only when the worker starts
