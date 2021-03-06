require 'bundler'

require 'base64'
require 'openssl'
require 'yajl'
require 'mini_fb'
require 'httparty'

require 'buddy/middleware'

require 'buddy/user'
require 'buddy/service'
require 'buddy/session'


module Buddy
  @buddy_config = {}

  class << self
    attr_accessor :logger, :rest_api_client

    def load_configuration(yaml)
      return false unless File.exist?(yaml)
      @buddy_config = YAML.load(ERB.new(File.read(yaml)).result)[::Rails.env] || false

      unless self.config['default'].nil?
        ActiveSupport::Deprecation.warn('Support for multiple apps has been removed and your config format is deprecated. Please remove your app keys (or just the "default" key)')
        self.config = self.config['default']
      end
      self.config
    end

    def config
      @buddy_config
    end
    alias :buddy_config :config
    alias :current_config :config

    def config=(c)
      @buddy_config = c
    end
  end
end

buddy_config = File.join(Bundler.root, "config", "buddy.yml")

BUDDY = Buddy.load_configuration(buddy_config)
Buddy.rest_api_client = Buddy::Service::RestApiClient.new

require 'buddy/rails/helpers'
require 'buddy/rails/controller'

require 'buddy/railtie'
