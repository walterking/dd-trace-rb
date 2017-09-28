module Datadog
  InvalidOptionError = Class.new(StandardError)
  # Configuratble provides configuration methods for a given class/module
  module Configurable
    IDENTITY = ->(x) { x }

    def self.included(base)
      base.singleton_class.send(:include, ClassMethods)
    end

    # ClassMethods
    module ClassMethods
      def set_option(name, value)
        name = name.to_sym

        invalid!(name) unless options.key?(name)

        options[name] = setters[name].call(value)
      end

      def get_option(name)
        invalid!(name) unless options.key?(name)

        options[name]
      end

      def configure_pin(pin)
        pin.config = Hash(pin.config).merge(options)
      end

      private

      def option(name, opts = {})
        name = name.to_sym
        setters[name] = opts.fetch(:setter, IDENTITY)
        options[name] = opts[:default]
        define_methods_for(name) if opts.fetch(:define_method, false)
      end

      def define_methods_for(name)
        self.singleton_class.class_eval do
          define_method(name) { get_option(name) }
          define_method("#{name}=") { |value| set_option(name, value) }
        end
      end

      def options
        @options ||= {}
      end

      def setters
        @setters ||= {}
      end

      def invalid!(name)
        raise(InvalidOptionError, "#{self} doesn't have the option: #{name}")
      end
    end
  end
end
