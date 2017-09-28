require 'ddtrace/configurable'

module Datadog
  class ConfigurableTest < Minitest::Test
    def setup
      @module = Module.new { include(Configurable) }
    end

    def test_option_methods
      assert_respond_to(@module, :set_option)
      assert_respond_to(@module, :get_option)
      assert_respond_to(@module, :configure_pin)
    end

    def test_option_default
      @module.class_eval do
        option :foo, default: :bar
      end

      assert_equal(:bar, @module.get_option(:foo))
    end

    def test_setting_an_option
      @module.class_eval do
        option :foo, default: :bar
      end

      @module.set_option(:foo, 'baz!')
      assert_equal('baz!', @module.get_option(:foo))
    end

    def test_custom_setter
      @module.class_eval do
        option :shout, setter: ->(v) { v.upcase }
      end

      @module.set_option(:shout, 'loud')
      assert_equal('LOUD', @module.get_option(:shout))
    end

    def test_pin_configuration
      @module.class_eval do
        option :foo
      end

      pin = Pin.new(:test_service)
      @module.set_option(:foo, :bar)
      @module.configure_pin(pin)

      assert_equal(:bar, pin.config[:foo])
    end

    def test_invalid_option
      assert_raises(InvalidOptionError) do
        @module.set_option(:bad_option, 'foo')
      end

      assert_raises(InvalidOptionError) do
        @module.get_option(:bad_option)
      end
    end

    def test_define_method_option
      @module.class_eval do
        option :foo, define_method: true
      end

      assert_respond_to(@module, :foo)
      assert_respond_to(@module, :foo=)

      @module.foo = :bar
      assert_equal(:bar, @module.foo)
    end
  end
end
