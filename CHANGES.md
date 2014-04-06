0.0.10 (2014-04-06)
-------------------

* Fix mri 2.0 trap and celluloid issue (https://github.com/celluloid/celluloid/pull/121)
* Use celluloid-0.15.2

0.0.9
-------------------

* Manual initialization
* Improved AWS::SQS configuration
* Clear active connections for ActiveRecord
* Add simple api for workers: `YourWorker.size`, `YourWorker.perform_async(params)`
