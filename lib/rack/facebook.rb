module Rack
  # This Rack middleware checks the signature of Facebook params, and
  # converts them to Ruby objects when appropiate. Also, it converts
  # the request method from the Facebook POST to the original HTTP
  # method used by the client.
  #
  # If the signature is wrong, it returns a "400 Invalid Facebook Signature".
  #
  # Optionally, it can take a block that receives the Rack environment
  # and returns a value that evaluates to true when we want the middleware to
  # be executed for the specific request.
  #
  # == Usage
  #
  # In your config.ru:
  #
  #   require 'rack/facebook'
  #   use Rack::Facebook, "my_facebook_secret_key"
  #
  # Using a block condition:
  #
  #   use Rack::Facebook, "my_facebook_secret_key" do |env|
  #     env['REQUEST_URI'] =~ /^\/facebook_only/
  #   end
  #

  module Facebook
    class RemoteIp
      def initialize(app)
        @app = app
      end

      def call(env)
        env['REMOTE_ADDR'] = env['X-FB-USER-REMOTE-ADDR'] if env['X-FB-USER-REMOTE-ADDR']
        @app.call(env)
      end
    end

    class ParamsParser
      def initialize(app, &condition)
        @app = app
        @condition = condition
      end

      def call(env)
        return @app.call(env) unless @condition.nil? || @condition.call(env)

        request = Rack::Request.new(env)

        signed_request = request.params["signed_request"]
        if signed_request
          signature, signed_params = signed_request.split('.')

          unless signed_request_is_valid?(Buddy.current_config['secret'], signature, signed_params)
            return Rack::Response.new(["Invalid Facebook signature"], 400).finish
          end

          signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))
          signed_params.each do |k,v|
            request.params[k] = v
          end
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
    end
  end
end
