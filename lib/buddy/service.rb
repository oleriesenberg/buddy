require 'observer'
module Buddy
  class OAuthException < ArgumentError
  end

  module Service
    class << self
      def call(api_method, params = {}, options = {})
        Buddy.caller.call(api_method, params, options)
      end

      def get(resource, params = {})
        result = GraphApiClient.get(resource, :query => params).parsed_response
        raise OAuthException.new(result["error"]["message"]) if result["error"]
        result
      end

      def post(resource, params = {})
        result = GraphApiClient.post(resource, :query => params).parsed_response
        raise OAuthException.new(result["error"]["message"]) if result["error"]
        result
      end
    end

    class GraphApiClient
      include HTTParty
      base_uri 'https://graph.facebook.com'
    end

    class Caller
      include Observable
      def call(api_method, params = {}, options = {})
        begin
          application = options[:app] || 'default'
        rescue NoMethodError => e
          raise ArgumentError.new("app not specified in buddy.yml")
        end

        changed
        notify_observers(api_method, params, options)

	fun = case api_method
	  when 'fql.query'
            -> { MiniFB.fql(params[:access_token], params[:query], options) }
          when 'fql.multiquery'
            -> { MiniFB.multifql(params[:access_token], params[:queries], options) }
          else
            -> do
	      if params[:access_token]
	        options[:params] = params
                MiniFB.rest(params[:access_token], api_method, options)
              else
                MiniFB.call(Buddy.buddy_config[application]["api_key"],
                  Buddy.buddy_config[application]["secret"],
                  api_method,
                  params.stringify_keys)
              end
	    end
	end

        result = nil
        time = Benchmark.realtime do
          result = fun.call
        end
        Buddy.logger.info("Calling #{api_method} (#{params.inspect}) - #{time}")
        result
      end
    end
  end
end
