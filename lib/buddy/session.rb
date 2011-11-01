require 'buddy/session/base'
require 'buddy/session/app'
require 'buddy/session/user'

module Buddy
  module Session
    def self.create(app_id = nil, secret_key = nil)
      Buddy::Session::User.create(app_id, secret_key)
    end
  end
end