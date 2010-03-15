module Buddy
  module Service
    class << self
      def call(api_method, params = {}, options = {})
        begin
	  app = options[:app] || 'default'
	rescue NoMethodError => e
	  raise ArgumentError.new("app not specified in buddy.yml")
	end

        MiniFB.call(Buddy.buddy_config[app]["api_key"], Buddy.buddy_config[app]["secret"],
                    api_method, params.stringify_keys)
      end
    end
  end
end
