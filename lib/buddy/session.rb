module Buddy
  class Session
    def self.create(api_key = nil, secret_key = nil)
      api_key ||= self.api_key
      secret_key ||= self.secret_key
      raise ArgumentError unless !api_key.nil? && !secret_key.nil?
      new(api_key, secret_key)
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
      params.merge!(:uids => uid, :session_key => session_key)
      Buddy::Service.call(api_method, params, options)
    end

    def get(resource, params = {})
      params.merge!(:access_token => access_token)
      Buddy::Service.get(resource, params)
    end

    def login_url(options = {})
#      options = default_login_url_options.merge(options)
#      "http://www.facebook.com/connect/uiserver.php?app_id=#{Buddy.current_config['app_id']}&next=&display=page&locale=de_DE&return_session=0&fbconnect=0&canvas=1&legacy_return=1&method=permissions.request#{"&perms="+Buddy.current_config['perms'] if Buddy.current_config['perms']}#{login_url_optional_parameters(options)}"
      options = default_login_url_options.merge(options)
      "http://www.facebook.com/login.php?api_key=#{Buddy.current_config['api_key']}&v=1.0#{login_url_optional_parameters(options)}"
    end

    def install_url(options = {})
      options = default_login_url_options.merge(options)
      "http://www.facebook.com/connect/uiserver.php?app_id=#{Buddy.current_config['app_id']}&next=&display=page&locale=de_DE&return_session=0&fbconnect=0&canvas=1&legacy_return=1&method=permissions.request#{"&perms="+Buddy.current_config['perms'] if Buddy.current_config['perms']}#{login_url_optional_parameters(options)}"
    end



    # The url to get user to approve extended permissions
    # http://wiki.developers.facebook.com/index.php/Extended_permission
    #
    # permissions:
    # * email
    # * offline_access
    # * status_update
    # * photo_upload
    # * video_upload
    # * create_listing
    # * create_event
    # * rsvp_event
    # * sms
    # * read_mailbox
    def permission_url(permission,options={})
      options = default_login_url_options.merge(options)
      options = add_next_parameters(options)
      options << "&ext_perm=#{permission}"
      "#{Facebooker.permission_url_base}#{options.join}"
    end

    def connect_permission_url(permission,options={})
      options = default_login_url_options.merge(options)
      options = add_next_parameters(options)
      options << "&ext_perm=#{permission}"
      "#{Facebooker.connect_permission_url_base}#{options.join}"
    end

    def install_url_optional_parameters(options)
      optional_parameters = []
      optional_parameters += add_next_parameters(options)
      optional_parameters.join
    end

    def add_next_parameters(options)
      opts = []
      opts << "&next=#{CGI.escape(options[:next])}" if options[:next]
      opts << "&next_cancel=#{CGI.escape(options[:next_cancel])}" if options[:next_cancel]
      opts
    end

    def login_url_optional_parameters(options)
      # It is important that unused options are omitted as stuff like &canvas=false will still display the canvas.
      optional_parameters = []
      optional_parameters += add_next_parameters(options)
      optional_parameters << "&skipcookie=true" if options[:skip_cookie]
      optional_parameters << "&hide_checkbox=true" if options[:hide_checkbox]
      optional_parameters << "&canvas=true" if options[:canvas]
      optional_parameters << "&fbconnect=true" if options[:fbconnect]
      optional_parameters << "&return_session=true" if options[:return_session]
      optional_parameters << "&session_key_only=true" if options[:session_key_only]
      optional_parameters << "&req_perms=#{options[:req_perms]}" if options[:req_perms]
      optional_parameters.join
    end

    def default_login_url_options
      {}
    end

    def initialize(api_key, secret_key)
      @api_key        = api_key
      @secret_key     = secret_key
      @batch_request  = nil
      @session_key    = nil
      @access_token   = nil
      @uid            = nil
      @auth_token     = nil
      @secret_from_session = nil
      @expires        = nil
    end

    def secret_for_method(method_name)
      @secret_key
    end

    def auth_token
      @auth_token ||= Buddy::Service.call('facebook.auth.createToken')
    end

    def infinite?
      @expires == 0
    end

    def expired?
      @expires.nil? || (!infinite? && Time.at(@expires) <= Time.now)
    end

    def secured?
      !@session_key.nil? && !expired?
    end

    def secure!(args = {})
      response = Buddy::Service.call('facebook.auth.getSession', {:auth_token => auth_token, :generate_session_secret => args[:generate_session_secret]}) ? "1" : "0"
      secure_with!(response['session_key'], response['uid'], response['expires'], response['secret'])
    end

    def secure_with_session_secret!
      self.secure!(:generate_session_secret => true)
    end

    def secure_with!(session_key, access_token, uid = nil, expires = nil, secret_from_session = nil)
      @session_key = session_key
      @access_token = access_token
      @uid = uid ? Integer(uid) : Buddy::Service.call('facebook.users.getLoggedInUser', {:session_key => session_key})
      @expires = expires ? Integer(expires) : 0
      @secret_from_session = secret_from_session
    end

    def user
      @user ||= Buddy::User.new(@uid, self)
    end

    def uid
      @uid
    end

    def session_key
      @session_key
    end

    def access_token
      @access_token
    end
  end
end
