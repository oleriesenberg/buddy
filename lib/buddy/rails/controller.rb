module Buddy
  module Rails
    module Controller
      include Buddy::Helpers::UrlFor

      def self.included(controller)
        controller.helper_method :request_comes_from_facebook?
      end

      def js_redirect_to(uri, target = 'self')
        render(:text => "<script>#{target.to_s}.location.href='#{uri}'</script>", :layout => false) if !request_is_facebook_tab?
      end

      def top_redirect_to(uri)
        js_redirect_to(uri, :top)
      end

      private
      def facebook_session
        session[:facebook_session]
      end

      def request_comes_from_facebook?
        !params[:signed_request].blank? # It already has been verified in middleware, so we can trust it here.
      end

      def application_is_installed?
        facebook_session && facebook_session.secured?
      end

      def request_is_facebook_canvas?
        params[:fb] && params[:fb][:profile_id].blank?
      end

      def request_is_facebook_tab?
        params[:fb] && !params[:fb][:profile_id].blank?
      end

      def clear_facebook_session_information
        session[:facebook_session] = nil
        @facebook_session          = nil
      end

      def new_facebook_session
        Buddy::Session::User.create(Buddy.config['app_id'], Buddy.config['secret'])
      end

      def set_facebook_session
        Buddy::Session::User.current = facebook_session
        return facebook_session.secured?
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
