require 'observer'
module Buddy
  module Service
    class << self
      def call(api_method, params = {}, options = {})
        Buddy.caller.call(api_method, params, options)
      end

      def get(resource, params = {})
        GraphApiClient.get(resource, :query => params)
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

        result = nil
        time = Benchmark.realtime do
          result = MiniFB.call(Buddy.buddy_config[application]["api_key"],
            Buddy.buddy_config[application]["secret"],
            api_method,
            params.stringify_keys)
        end
        Buddy.logger.info("Calling #{api_method} (#{params.inspect}) - #{time}")
        result
      end
    end
  end
end
