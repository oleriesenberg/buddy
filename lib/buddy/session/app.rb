module Buddy
  module Session
    class App < Base
      class << self
        def current
          Thread.current['facebook_app_session']
        end

        def current=(session)
          Thread.current['facebook_app_session'] = session
        end
      end

      def access_token
        @access_token ||= Buddy::Service::GraphApiClient.get('/oauth/access_token', :query => {
          :client_id => self.class.app_id,
          :client_secret => self.class.secret_key,
          :grant_type => 'client_credentials'
        }).body.split('=').last
      end
    end
  end
end
