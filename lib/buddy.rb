require 'mini_fb'

module Buddy
  @buddy_config = {}

  class << self
    def load_configuration(yaml)
      return false unless File.exist?(yaml)
      @buddy_config = YAML.load(ERB.new(File.read(yaml)).result)[Rails.env]

      buddy_config
    end

    def buddy_config
      @buddy_config
    end

    attr_accessor :logger

    def set_asset_host_to_callback_url
      buddy_config[app]['set_asset_host_to_callback_url']
    end

    def timeout(app = 'default')
      buddy_config[app]['timeout']
    end
  end
end

buddy_config = "#{Bundler.root}/config/buddy.yml"

BUDDY = Buddy.load_configuration(buddy_config)

