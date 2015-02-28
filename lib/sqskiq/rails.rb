module Sqskiq
  class Rails < ::Rails::Engine
    initializer 'sqskiq' do
      # Use patched psych for autoloading constants in rails
      require 'sqskiq/psych'
    end
  end if defined?(::Rails)
end
