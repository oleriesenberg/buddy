module Buddy
  class Session
    def self.create(app_id = nil, secret_key = nil)
      app_id     ||= self.app_id
      secret_key ||= self.secret_key
      raise ArgumentError unless !app_id.nil? && !secret_key.nil?
      new(app_id, secret_key)
    end

    def self.app_id
      Buddy.current_config["app_id"]
    end

    def self.api_key
      Buddy.current_config["api_key"]
    end

    def self.secret_key
       Buddy.current_config["secret"]
    end

    def self.current
      Thread.current['facebook_session']
    end

    def self.current=(session)
      Thread.current['facebook_session'] = session
    end

    def call(api_method, params = {}, options = {})
      params.merge!(:uids => uid, :access_token => access_token)
      Buddy::Service.call(api_method, params, options)
    end

    def get(resource, params = {})
      params.merge!(:access_token => access_token) unless params[:access_token]
      Buddy::Service.get(resource, params)
    end

    def post(resource, params = {})
      params.merge!(:access_token => access_token) unless params[:access_token]
      Buddy::Service.post(resource, params)
    end

    def install_url(options = {})
      "http://www.facebook.com/connect/uiserver.php?app_id=#{Buddy.current_config['app_id']}&next=#{options[:next]}&display=page&canvas=1&legacy_return=1&method=permissions.request#{"&perms="+Buddy.current_config['perms'] if Buddy.current_config['perms']}"
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
