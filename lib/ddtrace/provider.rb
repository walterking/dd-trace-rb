module Datadog
  # DefaultContextProvider is a default context provider that retrieves
  # all contexts from the current thread-local storage. It is suitable for
  # synchronous programming.
  class DefaultContextProvider
    # Initializes the default context provider with a thread-bound context.
    def initialize
      reset
    end

    # Return the current context.
    def context
      @context.local
    end

    # Setup a new context
    def reset(context = Datadog::ThreadLocalContext.new)
      @context = context
    end
  end
end
