require 'observer'
module Buddy
  class OAuthException < ArgumentError
  end

  module Service
    class << self
      def call(api_method, params = {}, options = {})
        Buddy.rest_api_client.call(api_method, params, options)
      end

      def get(resource, params = {})
        call_graph(:get, resource, params)
      end

      def post(resource, params = {})
        call_graph(:post, resource, params)
      end

      def delete(resource, params = {})
        call_graph(:delete, resource, params)
      end

      private
      def call_graph(method, resource, params)
        result = nil
        time = Benchmark.realtime do
          result = GraphApiClient.send(method, resource, :query => params).parsed_response
        end
        Buddy.logger.info("GraphAPI: #{method} #{resource} - #{time}") if Buddy.config['logging_enabled']

        raise OAuthException.new(result["error"]["message"]) if result.is_a?(Hash) && result["error"]
        result
      end
    end

    class GraphApiClient
      include HTTParty
      base_uri 'https://graph.facebook.com'
    end

    class RestApiClient
      include Observable
      def call(api_method, params = {}, options = {})
        changed
        notify_observers(api_method, params, options)

        fun = case api_method
          when 'fql.query'
            lambda { MiniFB.fql(params[:access_token], params[:query], options) }
          when 'fql.multiquery'
            lambda { MiniFB.multifql(params[:access_token], params[:queries], options) }
          else
            lambda do
              if params[:access_token]
                options[:params] = params
                MiniFB.rest(params[:access_token], api_method, options)
              else
                MiniFB.call(Buddy.config["api_key"],
                  Buddy.config["secret"],
                  api_method,
                  params.stringify_keys)
              end
            end
        end

        result = nil
        time = Benchmark.realtime do
          result = fun.call
        end
        Buddy.logger.info("RestAPI: #{api_method} (#{params.inspect}) - #{time}") if Buddy.config['logging_enabled']
        result
      end
    end
  end
end
