require 'bundler'

require 'base64'
require 'openssl'
require 'yajl'
require 'mini_fb'
require 'httparty'

require 'rack/facebook'

require 'buddy/user'
require 'buddy/session'
require 'buddy/service'

module Buddy
  @buddy_config = {}

  class << self
    attr_accessor :logger, :caller

    def load_configuration(yaml)
      return false unless File.exist?(yaml)
      @buddy_config = YAML.load(ERB.new(File.read(yaml)).result)[::Rails.env]
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

    def current_config
      Thread.current['current_buddy_config']
    end

    def current_config=(config)
      Thread.current['current_buddy_config'] = config
    end
  end
end

buddy_config = File.join(Bundler.root, "config", "buddy.yml")

BUDDY = Buddy.load_configuration(buddy_config)
Buddy.logger = Rails.logger
Buddy.caller = Buddy::Service::Caller.new

require 'buddy/rails/backwards_compatible_param_checks'
require 'buddy/rails/controller'
require 'buddy/rails/controller_extensions'

require 'buddy/railtie'
