require 'ddtrace/ext/app_types'

module Datadog
  module Contrib
    module ResqueJob
  		def around_perform(*args)
  			rails_config = ::Rails.configuration.datadog_trace
  		  Datadog::Tracer.log.debug("///////INIT RESQJOB")
        base_config = DEFAULT_CONFIG.merge(rails_config)
  			@tracer = Datadog.tracer
  			Datadog::Tracer.debug_logging=true
  			@tracer.trace('resque.job', service: 'resque.job') do |span| 
        	span.resource = 'foobar'
        	span.span_type = Ext::AppTypes::WEB
        	span.set_tag('resque.queue', 'bonjourhello')
        	span.set_tag('resque.job', self)
        	yield  
  	  		Datadog::Tracer.log.debug("/////// DONE JOB")
  			end
  		end	
		end
  end
end

