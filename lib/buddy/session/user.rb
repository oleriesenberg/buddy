module Buddy
  module Session
    class User < Base

      class << self
        def app_id
          Buddy.current_config["app_id"]
        end

        def secret_key
           Buddy.current_config["secret"]
        end

        def current
          Thread.current['facebook_session']
        end

        def current=(session)
          Thread.current['facebook_session'] = session
        end
      end

      def install_url(options = {})
        "https://www.facebook.com/dialog/oauth?client_id=#{Buddy.current_config['app_id']}&redirect_uri=#{options[:next]}#{"&scope="+Buddy.current_config['perms'] if Buddy.current_config['perms']}"
      end

      def initialize(app_id, secret_key)
        @app_id         = app_id
        @secret_key     = secret_key
        @uid            = nil
        @access_token   = nil
        @expires        = nil
      end

      def secure!(uid, access_token, expires)
        @uid          = uid
        @access_token = access_token
        @expires      = expires
      end

      def infinite?
        @expires == 0
      end

      def expired?
        @expires.nil? || (!infinite? && Time.at(@expires) <= Time.now)
      end

      def secured?
        !@uid.nil? && !@access_token.nil? && !expired?
      end

      def user
        @user ||= Buddy::User.new(@uid, self)
      end

      def uid
        @uid
      end

      def access_token
        @access_token
      end

      def expires
        @expires
      end
    end
  end
end
