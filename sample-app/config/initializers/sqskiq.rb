Sqskiq.configure do |config|
  config.configuration = {
    access_key_id: ENV['AWSAccessKeyId'],
    secret_access_key: ENV['AWSSecretKey']
  }
end
