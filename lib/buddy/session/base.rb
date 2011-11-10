module Buddy
  module Session
    class Base
      class << self
        def create(app_id = nil, secret_key = nil)
          app_id     ||= self.app_id
          secret_key ||= self.secret_key
          raise ArgumentError unless !app_id.nil? && !secret_key.nil?
          new(app_id, secret_key)
        end

        def app_id
          Buddy.config["app_id"]
        end

        def secret_key
          Buddy.config["secret"]
        end
      end

      def call(api_method, params = {}, options = {})
        params.merge!(:uids => uid, :access_token => access_token)
        Buddy::Service.call(api_method, params, options)
      end

      def get(resource, params = {})
        graph_http_req(:get, resource, params)
      end

      def post(resource, params = {})
        graph_http_req(:post, resource, params)
      end

      def delete(resource, params = {})
        graph_http_req(:delete, resource, params)
      end

      private
      def graph_http_req(method, resource, params = {})
        params.merge!(:access_token => access_token) unless params[:access_token]
        Buddy::Service.send(method, resource, params)
      end
    end
  end
end
