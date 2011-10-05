require 'buddy'
require 'buddy/rails/helpers'
require 'rails'

module Buddy
  class Railtie < ::Rails::Railtie
    initializer "buddy.configure_rails_initialization" do |app|
      app.config.middleware.swap(::Rails::Rack::Logger, Buddy::Middleware::Logger)
      app.config.middleware.insert_before(Buddy::Middleware::Logger, Buddy::Middleware::MethodOverride)
      app.config.middleware.insert_before(ActionDispatch::ParamsParser, Buddy::Middleware::ParamsParser)
    end

    initializer "buddy.configure_logger", :after => :initialize_logger do |app|
      Buddy.logger = ::Rails.logger
    end

    ActionView::Helpers::UrlHelper.send(:include, Buddy::Helpers::UrlFor)
    ActionController::Base.send(:include, Buddy::Helpers::UrlFor)
    ActionController::Base.send(:include, Buddy::Rails::Controller)
  end
end
