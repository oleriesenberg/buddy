module Buddy
  module Rails
    module Controller
      include Buddy::Rails::BackwardsCompatibleParamChecks
      include Buddy::Rails::UrlHelper

      def self.included(controller)
        controller.helper_method :request_comes_from_facebook?
      end

      def js_redirect_to(uri, target = nil)
        if request_is_facebook_canvas? and !request_is_facebook_tab? and !target.nil?
          render(:text => "<script>#{target.to_s}.location.href='#{uri}'</script>", :layout => false)
        elsif request_is_facebook_canvas? and !request_is_facebook_tab?
          render(:text => "<script>self.location.href='#{uri}'</script>", :layout => false)
        end
      end

      def top_redirect_to(uri)
        js_redirect_to(uri, :top)
      end

      private
      def facebook_session
        @facebook_session
      end

      def application_is_installed?
        !params[:fb][:oauth_token].blank?
      end

      def request_is_facebook_canvas?
        params[:fb][:profile_id].blank?
      end

      def request_is_facebook_tab?
        !params[:fb][:profile_id].blank?
      end

      def clear_facebook_session_information
        session[:facebook_session] = nil
        @facebook_session          = nil
      end

      def new_facebook_session
        Buddy::Session.create(Buddy.current_config['app_id'], Buddy.current_config['secret'])
      end

      def create_facebook_session
        @facebook_session = new_facebook_session
        @facebook_session.secure!(params[:fb][:user_id], params[:fb][:oauth_token], params[:fb][:expires])
        @facebook_session.secured?
      end

      def set_facebook_session
        session_set = !@facebook_session.blank? && @facebook_session.secured?
        unless session_set
          session_set = create_facebook_session
          session[:facebook_session] = @facebook_session if session_set
        end
        if session_set
          Session.current = @facebook_session
        end
        return session_set
      end

      def ensure_facebook_session
        return create_new_facebook_session_and_redirect! unless application_is_installed?
        set_facebook_session || create_new_facebook_session_and_redirect!
      end

      def default_after_install_url
        url_for('/')
      end

      def create_new_facebook_session_and_redirect!
        session[:facebook_session] = new_facebook_session
        next_url = defined?(:after_install_url) ? default_after_install_url : after_install_url
        top_redirect_to session[:facebook_session].install_url({:next => next_url}) if @installation_required
      end

      def ensure_application_is_installed
        @installation_required = true
        ensure_facebook_session
      end
    end
  end
end
