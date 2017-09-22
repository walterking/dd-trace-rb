require 'ddtrace/ext/app_types'

module Datadog
  module Contrib
    module ResqueJob
      def around_perform(*args)
  			rails_config = ::Rails.configuration.datadog_trace
  		  Datadog::Tracer.log.debug("///////INIT RESQJOB")
        #base_config = DEFAULT_CONFIG.merge(rails_config)
  			@tracer = Datadog.tracer
  			Datadog::Tracer.debug_logging=true
  			@testvar = 0
        @tracer.trace('resque.job', service: 'resque.job') do |span| 
        	@testvar = span
          span.resource = 'foobar'
        	span.span_type = Ext::AppTypes::WEB
        	span.set_tag('resque.queue', 'bonjourhello')
        	span.set_tag('resque.job', self)
        	yield 
  			end
  	  	Datadog::Tracer.log.debug("/////// DONE JOB")
        Datadog::Tracer.log.debug(@testvar.finished?)
        sleep 2
  		end	
      def on_failure_retry(e, *args)
        Datadog::Tracer.log.error("Performing #{self} caused an exception (#{e}). Retrying...")
        Resque.enqueue self, *args
      end
		end
  end
end

