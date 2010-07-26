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
        fb_sig, fb_params = nil, nil

        [ request.POST, request.GET ].each do |params|
          fb_sig, fb_params = fb_sig_and_params( params )
          break if fb_sig
        end

        return @app.call(env) if fb_params.empty?

        Buddy.use_application(fb_params['api_key'])
        unless signature_is_valid?(fb_params, fb_sig)
          return Rack::Response.new(["Invalid Facebook signature"], 400).finish
        end
        env['REQUEST_METHOD'] = fb_params["request_method"] if fb_params["request_method"]
        convert_parameters!(request.params)

        signed_request = request.params["signed_request"]
        if signed_request
          signature, signed_params = signed_request.split('.') 
        else
          signature, signed_params = []
        end

        unless signed_request_is_valid?(Buddy.current_config['secret'], signature, signed_params)
          return Rack::Response.new(["Invalid Facebook signature"], 400).finish
        end
        
        signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))
        signed_params.each do |k,v|
          request.params[k] = v
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

      def fb_sig_and_params( params )
        return nil, [] unless params['fb_sig']
        return params['fb_sig'], extract_fb_sig_params(params)
      end

      def extract_fb_sig_params(params)
        params.inject({}) do |collection, (param, value)|
          collection[param.sub(/^fb_sig_/, '')] = value if param[0,7] == 'fb_sig_'
          collection
        end
      end

      def signature_is_valid?(fb_params, actual_sig)
        raw_string = fb_params.map{ |*args| args.join('=') }.sort.join
        expected_signature = Digest::MD5.hexdigest([raw_string, Buddy.current_config['secret']].join)
        actual_sig == expected_signature
      end

      def convert_parameters!(params)
        params.each do |key, value|
          case key
          when 'fb_sig_added', 'fb_sig_in_canvas', 'fb_sig_in_new_facebook', 'fb_sig_position_fix', 'fb_sig_is_ajax'
            params[key] = value == "1"
          when 'fb_sig_expires', 'fb_sig_profile_update_time', 'fb_sig_time'
            params[key] = value == "0" ? nil : Time.at(value.to_f)
          when 'fb_sig_friends'
            params[key] = value.split(',')
          end
        end
      end
    end
  end
end
