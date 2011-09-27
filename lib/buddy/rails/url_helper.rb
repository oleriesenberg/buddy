module Buddy
  module Rails
    module UrlHelper
      def url_for(options = {})
        only_path = options[:only_path] || false
        options.merge!({ :only_path => true }) if options.is_a?(Hash) && options[:canvas] != false

        url = super(options)

        if url[0..6] == 'http://' or url[0..7] == 'https://'
          url
        elsif options.is_a?(Hash) && options[:canvas] == false
          base = only_path ? '' : Buddy.current_config["callback_url"]
          base + url
        else
          "http://apps.facebook.com/#{Buddy.current_config["canvas_page_name"]}#{url}"
        end
      end
    end
  end
end
