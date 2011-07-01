require 'bundler'

require 'base64'
require 'openssl'
require 'yajl'
require 'mini_fb'
require 'httparty'

require 'buddy/middleware'

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
Buddy.logger = Rails.logger
Buddy.caller = Buddy::Service::Caller.new

require 'buddy/rails/url_helper'
require 'buddy/rails/controller'
require 'buddy/rails/controller_extensions'

require 'buddy/railtie'
