module Datadog
  # Configuration provides a unique access point for configurations
  class Configuration
    def initialize(options = {})
      @registry = options.fetch(:registry, Datadog.registry)
    end

    def configure
      yield(self)
    end

    def get(contrib, param, opts = {})
      pin = opts[:pin]
      value_from_pin = Hash(pin.config)[param] if pin
      value_from_pin || @registry[contrib].get_option(param)
    end

    def use(integration_name, options = {})
      integration = @registry[integration_name]

      options.each_with_object(integration) do |(name, value), klass|
        klass.set_option(name, value)
      end

      integration.patch if integration.respond_to?(:patch)
    end
  end
end
