require 'spec_helper'

describe Sqskiq do
  subject { Sqskiq }

  let(:default_pool_sizes) { Sqskiq::DEFAULT_POOL_SIZE }

  context "default values" do
    its(:pools) { should include(default_pool_sizes) }

    context "can overwrite defaults" do
      let(:custom_pool_size) { {fetcher: 5} }

      before {
        subject.configure do |config|
          config.pools = custom_pool_size
        end
      }

      its(:pools) { should include(custom_pool_size) }
    end
  end
end