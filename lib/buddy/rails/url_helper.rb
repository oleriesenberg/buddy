module Buddy
  module Rails
    module UrlHelper
      def url_for(options = {})
        options ||= {}
	opts = case options
	when Hash
          options.merge!({ :only_path => true }) #unless options[:canvas] == false
	else
	  options
	end
        url = super(opts)

	if options.is_a?(Hash) && options[:canvas] == false
	  "#{Buddy.current_config["callback_url"]}#{url}"
	else
	  "http://apps.facebook.com/#{Buddy.current_config["canvas_page_name"]}#{url}"
	end
      end
    end
  end
end
