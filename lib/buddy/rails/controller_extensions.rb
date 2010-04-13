module ::ActionController
  class Base
    def self.inherited_with_buddy(subclass)
      inherited_without_buddy(subclass)
      #if subclass.to_s == "ApplicationController"
        subclass.send(:include, Buddy::Rails::Controller)
        #subclass.helper Buddy::Rails::Helpers
      #end
    end
    class << self
      alias_method_chain :inherited, :buddy
    end
  end
end


# When making get requests, Facebook sends fb_sig parameters both in the query string
# and also in the post body. We want to ignore the query string ones because they are one
# request out of date
# We only do thise when there are POST parameters so that IFrame linkage still works
#class ActionController::Request
#  def query_parameters_with_buddy
#    if request_parameters.blank?
#      query_parameters_without_buddy
#    else
#      (query_parameters_without_buddy||{}).reject {|key,value| key.to_s =~ /^fb_sig/}
#    end
#  end

#  alias_method_chain :query_parameters, :buddy
#end
