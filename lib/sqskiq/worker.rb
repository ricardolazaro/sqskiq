require 'sqskiq/core_ext'

module Sqskiq
  module Worker

    module ClassMethods
      def run
        Sqskiq.bootstrap(sqskiq_options_hash, self)
      end

      def sqskiq_options(options)
        self.sqskiq_options_hash = options
      end
    end

    def self.included(base)
      base.send :extend,  ClassMethods
      base.class_attribute :sqskiq_options_hash
    end

  end

end