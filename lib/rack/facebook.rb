module Rack
  # This Rack middleware checks the signed_request, and
  # appends the payload to Rails params.
  #
  # If the signature is wrong, it returns a "400 Invalid Facebook Signature".
  #

  module Facebook
    class ParamsParser
      def initialize(app, &condition)
        @app = app
        @condition = condition
      end

      def call(env)
        return @app.call(env) unless @condition.nil? || @condition.call(env)

        request = Rack::Request.new(env)

        request.params["signed_request"] = env['HTTP_X_SIGNED_REQUEST'] if env['HTTP_X_SIGNED_REQUEST'] && !request.params["signed_request"]
        signed_request = request.params["signed_request"]
        if signed_request
          signature, signed_params = signed_request.split('.')

          unless signed_request_is_valid?(Buddy.current_config['secret'], signature, signed_params)
            return Rack::Response.new(["Invalid Facebook signature"], 400).finish
          end

          signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))
          request.params[:fb] = signed_params
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
