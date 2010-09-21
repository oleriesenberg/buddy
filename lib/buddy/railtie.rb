require 'buddy'
require 'buddy/rails/url_helper'
require 'rails'

module Buddy
  class Railtie < ::Rails::Railtie
    initializer "buddy.configure_rails_initialization" do |app|
      app.config.middleware.insert_before(ActionDispatch::ParamsParser, ::Rack::Facebook::ParamsParser)
      ActionView::Helpers::UrlHelper.send(:include, Buddy::Rails::UrlHelper)
      Buddy.logger = ::Rails.logger
    end
  end
end
