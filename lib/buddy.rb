require 'mini_fb'

require 'rack/facebook'

require 'buddy/service'

module Buddy
  @buddy_config = {}

  class << self
    attr_accessor :current_config
    attr_accessor :logger

    def load_configuration(yaml)
      return false unless File.exist?(yaml)
      @buddy_config = YAML.load(ERB.new(File.read(yaml)).result)[Rails.env]
      self.current_config = buddy_config['default']

      buddy_config
    end

    def buddy_config
      @buddy_config
    end

    def set_asset_host_to_callback_url
      buddy_config[app]['set_asset_host_to_callback_url']
    end

    def timeout(app = 'default')
      buddy_config[app]['timeout']
    end

    def use_application(api_key)
      buddy_config.each do |c|
        if c[1]["api_key"] == api_key
          return self.current_config = c[1]
	end
      end
    end
  end
end

buddy_config = "#{Bundler.root}/config/buddy.yml"

BUDDY = Buddy.load_configuration(buddy_config)

