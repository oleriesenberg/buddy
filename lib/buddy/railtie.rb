require 'buddy'
require 'buddy/rails/url_helper'
require 'rails'

module Buddy
  class Railtie < ::Rails::Railtie
    initializer "buddy.configure_rails_initialization" do |app|
      app.config.middleware.swap(::Rails::Rack::Logger, Buddy::Middleware::Logger)
      app.config.middleware.insert_before(Buddy::Middleware::Logger, Buddy::Middleware::MethodOverride)
      app.config.middleware.insert_before(ActionDispatch::ParamsParser, Buddy::Middleware::ParamsParser)

      ActionView::Helpers::UrlHelper.send(:include, Buddy::Rails::UrlHelper)
      Buddy.logger = ::Rails.logger
    end
  end
end
