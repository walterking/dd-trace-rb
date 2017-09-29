require 'ddtrace/configuration'
require 'ddtrace/configurable'

module Datadog
  class ConfigurationTest < Minitest::Test
    def setup
      @registry = Registry.new
      @configuration = Configuration.new(registry: @registry)
    end

    def test_use_method
      contrib = Minitest::Mock.new
      contrib.expect(:patch, true)

      @registry.add(:example, contrib)
      @configuration.use(:example)

      assert_mock(contrib)
    end

    def test_module_configuration
      integration = Module.new do
        include Contrib::Base
        option :option1
        option :option2
      end

      @registry.add(:example, integration)

      @configuration.configure do |c|
        c.use :example, option1: :foo!, option2: :bar!
      end

      assert_equal(:foo!, integration.get_option(:option1))
      assert_equal(:bar!, integration.get_option(:option2))
    end

    def test_get
      integration = Module.new do
        include Contrib::Base
        option :option1, default: :value1
        option :option2, default: :value2
      end

      @registry.add(:example, integration)

      assert_equal(:value1, @configuration.get(:example, :option1))
      assert_equal(:value2, @configuration.get(:example, :option2))
    end
  end
end
