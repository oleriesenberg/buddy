module Buddy
  module Rails
    module Controller
      include Buddy::Rails::BackwardsCompatibleParamChecks
      def self.included(controller)
        controller.before_filter :set_facebook_request_format
        controller.helper_attr :facebook_session_parameters
        controller.helper_method :request_comes_from_facebook?
      end

      def redirect_to(*args)
        if request_is_for_a_facebook_canvas? and !request_is_facebook_tab?
          render :text => fbml_redirect_tag(*args)
        else
          super
        end
      end
      private
      def facebook_session
        @facebook_session
      end

      def session_already_secured?
        (@facebook_session = session[:facebook_session]) && session[:facebook_session].secured? if valid_session_key_in_session?
      end

      def user_has_deauthorized_application?
        # if we're inside the facebook session and there is no session key,
        # that means the user revoked our access
        # we don't want to keep using the old expired key from the cookie.
        request_comes_from_facebook? and params[:fb_sig_session_key].blank?
      end

      def clear_facebook_session_information
        session[:facebook_session] = nil
        @facebook_session=nil
      end

      def valid_session_key_in_session?
        #before we access the facebook_params, make sure we have the parameters
        #otherwise we will blow up trying to access the secure parameters
        if user_has_deauthorized_application?
          clear_facebook_session_information
          false
        else
          !session[:facebook_session].blank? &&  (params[:fb_sig_session_key].blank? || session[:facebook_session].session_key == facebook_params[:session_key])
        end
      end

      def create_facebook_session
        secure_with_facebook_params! || secure_with_token!
      end

      def secure_with_token!
        if params['auth_token']
          @facebook_session = new_facebook_session
          @facebook_session.auth_token = params['auth_token']
          @facebook_session.secure!
          @facebook_session
        end
      end

      def secure_with_session_secret!
        if params['auth_token']
          @facebook_session = new_facebook_session
          @facebook_session.auth_token = params['auth_token']
          @facebook_session.secure_with_session_secret!
          @facebook_session
        end
      end

      def secure_with_facebook_params!
        return unless request_comes_from_facebook?

        if ['user', 'session_key'].all? {|element| facebook_params[element]}
          @facebook_session = new_facebook_session
          @facebook_session.secure_with!(facebook_params['session_key'], params['oauth_token'], facebook_params['user'], facebook_params['expires'])
          @facebook_session
        end
      end

      def new_facebook_session
        Buddy::Session.create(Buddy.current_config['api_key'], Buddy.current_config['secret'])
      end

      def set_facebook_session
        # first, see if we already have a session
        session_set = session_already_secured?
        # if not, see if we can load it from the environment
        unless session_set
          session_set = create_facebook_session
          session[:facebook_session] = @facebook_session if session_set
        end
        if session_set
          #capture_facebook_friends_if_available!
          Session.current = facebook_session
        end
        return session_set
      end

      def facebook_parameter_conversions
        @facebook_parameter_conversions ||= Hash.new do |hash, key|
          lambda{|value| value}
        end.merge(
          'time'      => lambda{|value| Time.at(value.to_f)},
          'in_canvas' => lambda{|value| one_or_true(value)},
          'added'     => lambda{|value| one_or_true(value)},
          'expires'   => lambda{|value| zero_or_false(value) ? nil : Time.at(value.to_f)},
          'friends'   => lambda{|value| value.split(/,/)}
        )
      end

      def verified_facebook_params
        facebook_sig_params = params.inject({}) do |collection, pair|
          collection[pair.first.sub(/^fb_sig_/, '')] = pair.last if pair.first[0,7] == 'fb_sig_'
          collection
        end

        facebook_sig_params.inject(HashWithIndifferentAccess.new) do |collection, pair|
          collection[pair.first] = facebook_parameter_conversions[pair.first].call(pair.last)
          collection
        end
      end

      def facebook_params
        @facebook_params ||= verified_facebook_params
      end

      def application_is_installed?
        facebook_params['added']
      end

      def application_is_not_installed_by_facebook_user
        next_url = after_facebook_login_url || default_after_facebook_login_url
        redirect_to session[:facebook_session].install_url({:next => next_url})
      end

      def set_facebook_request_format
        if request_is_facebook_ajax?
          request.format = :fbjs
        elsif request_comes_from_facebook? && !request_is_facebook_iframe?
          request.format = :fbml
        end
      end

      def fbml_redirect_tag(url,*args)
        "<fb:redirect url=\"#{url_for(url)}\" />"
      end

      def request_is_fb_ping?
        !params['fb_sig'].blank?
      end

      def request_is_for_a_facebook_canvas?
        !params['fb_sig_in_canvas'].blank?
      end

      def request_is_facebook_tab?
        !params["fb_sig_in_profile_tab"].blank?
      end

      def request_is_facebook_iframe?
        !params["fb_sig_in_iframe"].blank?
      end

      def request_is_facebook_ajax?
        one_or_true(params["fb_sig_is_mockajax"]) || one_or_true(params["fb_sig_is_ajax"])
      end

      def ensure_authenticated_to_facebook
        set_facebook_session || create_new_facebook_session_and_redirect!
      end

      def after_facebook_login_url
        nil
      end

      def default_after_facebook_login_url
        omit_keys = ["_method", "format"]
        options = (params||{}).clone
        options = options.reject{|k,v| k.to_s.match(/^fb_sig/) or omit_keys.include?(k.to_s)}
        url_for(options)
      end

      def create_new_facebook_session_and_redirect!
        session[:facebook_session] = new_facebook_session
        next_url = after_facebook_login_url || default_after_facebook_login_url
        top_redirect_to session[:facebook_session].login_url({:next => next_url, :canvas=>params[:fb_sig_in_canvas]}) unless @installation_required
        false
      end

      def ensure_application_is_installed_by_facebook_user
        @installation_required = true
        returning ensure_authenticated_to_facebook && application_is_installed? do |authenticated_and_installed|
          application_is_not_installed_by_facebook_user unless authenticated_and_installed
        end
      end

      def request_comes_from_facebook?
        request_is_for_a_facebook_canvas? || request_is_facebook_ajax? || request_is_fb_ping?
      end
    end
  end
end
