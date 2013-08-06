# Sqskiq #

High performance, [Sidekiq](http://sidekiq.org)-like Amazon SQS messages consumer. It uses
[Celluloid](http://celluloid.io) to handle concurrent tasks.

## Usage

See a simple but complete rails app at (`sample-app`)[sample-app] directory.

### Installation

Add this line to your application's Gemfile:

    gem 'sqskiq' # point to github repo, if needed

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqskiq

### Create a worker to consume a queue

For example, to print messages from the `test` queue, just create a worker like this one:

    class SampleWorker
      include Sqskiq::Worker

      sqskiq_options queue_name: :test

      def perform(message)
        p "worker received #{message}"
      end
    end

### Configure

On rails apps, create a initializer (`config/initializers/qsqkiq.rb`):

    Sqskiq.configure do |config|
      config.aws_access_key_id = 'AWS_ACCESS_KEY_ID'
      config.aws_secret_access_key = 'AWS_SECRET_ACCESS_KEY'
    end

where `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are your credentials.

There are four thread pools:

* Fetchers: to get messages from SQS (2 by default)
* Batch processors: to manage a set of messages fetched from SQS (2 by default).
* Processors: to process each message locally (20 by default)
* Deleters: to inform to SQS that the message was consumed (2 by default)

You can also configure the pool sizes:

    ...
    config.pools = { processor: 10, fetcher: 5 } # keep :batch_processor and :deleter defaults
    ...


### Run it!

Create a `Procfile` to call the `run` method:

    sqs_test: rails runner 'SampleWorker.run'

*Tip:* use [Foreman](https://github.com/ddollar/foreman) to manage procfile processes
