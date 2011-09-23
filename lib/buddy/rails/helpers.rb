module Buddy
  module Helpers
    module UrlFor
      def url_for(options = nil)
        ::Rails.logger.debug("BUUUUUUDDY")
        only_path = options[:only_path] || false
        canvas = options.delete(:canvas)
        options.merge!({ :only_path => true }) if options.is_a?(Hash) && canvas != false

        url = super(options)

        if url[0..6] == 'http://'
          url
        elsif options.is_a?(Hash) && canvas == false
          base = only_path ? '' : Buddy.current_config["callback_url"]
          base + url
        else
          "http://apps.facebook.com/#{Buddy.current_config["canvas_page_name"]}#{url}"
        end
      end
    end
  end
end
