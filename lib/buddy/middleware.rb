module Buddy
  module Middleware

    class Logger < ::Rails::Rack::Logger
      private
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)
        path = request.fullpath

        method_s = request.request_method
        method_s += " (#{env['rack.methodoverride.original_method']})" if env['rack.methodoverride.original_method']

        info "\n\nStarted #{method_s} \"#{path}\" " \
             "for #{request.ip} at #{Time.now.to_default_s}"
      end
    end

    class MethodOverride
      HTTP_METHODS = %w(GET HEAD PUT POST DELETE OPTIONS)

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)

        method = 'GET' if request.post? && !request.xhr? && request.params['authenticity_token'].nil? && request.params['_method'].nil?
        method = request.params['_method'].to_s.upcase unless request.params['_method'].nil?

        if method && HTTP_METHODS.include?(method)
          env['rack.methodoverride.original_method'] = env['REQUEST_METHOD']
          env['REQUEST_METHOD'] = method
        end

       @app.call(env)
      end
    end

    # This Rack middleware checks the signed_request, and
    # appends the payload to Rails params.
    #
    # If the signature is wrong, it returns a "400 Invalid Facebook Signature".
    class ParamsParser
      def initialize(app, &condition)
        @app = app
        @condition = condition
      end

      def call(env)
        return @app.call(env) unless @condition.nil? || @condition.call(env)

        @request = Rack::Request.new(env)

        signed_request = env['HTTP_X_SIGNED_REQUEST'].split(',').first if env['HTTP_X_SIGNED_REQUEST']
        signed_request = @request.params["signed_request"] unless signed_request
        if signed_request
          signature, signed_params = signed_request.split('.')

          unless signed_request_is_valid?(Buddy.current_config['secret'], signature, signed_params)
            return Rack::Response.new(["Invalid Facebook signature"], 400).finish
          end

          signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))
          @request.params[:fb] = signed_params
          set_session(signed_params)
        elsif @request.cookies["fbs_#{Buddy.current_config['app_id']}"]
          payload = @request.cookies["fbs_#{Buddy.current_config['app_id']}"].chomp('"')
          payload.sub!('"', '') if payload.start_with?('"')
          set_session(Rack::Utils.parse_query(payload))
        end

        @app.call(env)
      end

      private

     # This function takes the app secret and the signed request, and verifies if the request is valid.
      def signed_request_is_valid?(secret, signature, params)
        sig = base64_url_decode(signature)
        expected_sig = OpenSSL::HMAC.digest('SHA256', secret, params.tr("-_", "+/"))
        return sig == expected_sig
      end

      # Ruby's implementation of base64 decoding reads the string in multiples of 6 and ignores any extra bytes.
      # Since facebook does not take this into account, this function fills any string with white spaces up to
      # the point where it becomes divisible by 6, then it replaces '-' with '+' and '_' with '/' (URL-safe decoding),
      # and decodes the result.
      def base64_url_decode(str)
        str = str + "=" * (6 - str.size % 6) unless str.size % 6 == 0
        return Base64.decode64(str.tr("-_", "+/"))
      end

      def set_session(payload)
        uid          = payload['user_id'] || payload['uid']
        access_token = payload['oauth_token'] || payload['access_token']
        expires      = payload['expires']

        @request.session['facebook_session'] = Buddy::Session.create(Buddy.current_config['app_id'], Buddy.current_config['secret'])
        @request.session['facebook_session'].secure!(uid.to_i, access_token, expires.to_i) unless uid.blank? or access_token.blank?
      end
    end
  end
end
