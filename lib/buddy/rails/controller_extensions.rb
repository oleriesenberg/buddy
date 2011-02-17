module ::ActionController
  class Base
    def self.inherited_with_buddy(subclass)
      inherited_without_buddy(subclass)
      subclass.send(:include, Buddy::Rails::Controller)
    end
    class << self
      alias_method_chain :inherited, :buddy
    end
  end
end
