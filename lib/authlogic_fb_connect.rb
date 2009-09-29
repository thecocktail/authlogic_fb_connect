require "authlogic_fb_connect/acts_as_authentic"
require "authlogic_fb_connect/session"

ActiveRecord::Base.send(:include, AuthlogicFbConnect::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicFbConnect::Session)
