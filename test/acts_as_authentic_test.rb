require File.dirname(__FILE__) + '/test_helper.rb'

class ActsAsAuthenticTest < ActiveSupport::TestCase
  
  def setup
    @api_key = "95a71599e8293s66f1f0a6f4aeab3df7"
    @secret_key = "3e4du8eea435d8e205a6c9b5d095bed1"
    ENV["FACEBOOK_API_KEY"] = @api_key
    ENV["FACEBOOK_SECRET_KEY"] = @secret_key
    @session = Facebooker::Session.create(@api_key, @secret_key)
    Authlogic::Session::Base.controller = controller
  end
  
  def controller
    @controller ||= FBConnectController.new
  end
  
  def test_included
   assert User.send(:acts_as_authentic_modules).include?(AuthlogicFbConnect::ActsAsAuthentic::Methods)
   assert_equal :validate_password_with_fb_connect?, User.validates_length_of_password_field_options[:if]
   assert_equal :validate_password_with_fb_connect?, User.validates_confirmation_of_password_field_options[:if]
   assert_equal :validate_password_with_fb_connect?, User.validates_length_of_password_confirmation_field_options[:if]
  end
  
  def test_password_not_required_on_create_with_facebook_session
    start_facebook_session_and_populate
    user = User.new
    user.name = controller.facebook_session.user.name
    user.email = "testing@desde1980.es"
    user.country = controller.facebook_session.user.current_location.country
    assert user.save
  end
  
  def test_password_required_on_create_without_facebook_session
    user = User.new
    user.name = "testing"
    user.email = "testing@desde1980.es"
    user.country = "España"
    assert !user.save
    assert user.errors.on(:password)
  end
  
  def test_password_not_required_on_update_for_facebook_user
    start_facebook_session
    yop = users(:yomismo)
    yop.name = "ahora me llamo yop"
    assert_nil yop.crypted_password
    assert yop.save
    assert_equal yop.name, "ahora me llamo yop"
  end
  
  def test_password_required_on_update_for_not_facebook_user
    yop = users(:yomismo)
    assert_nil yop.crypted_password
    assert !yop.save
    assert yop.errors.on(:password)
    assert yop.errors.on(:password_confirmation)
  end
  
  private

   def start_facebook_session
     establish_session(@session)
     controller.facebook_session = @session
     controller.params = {}
     controller.params[:user] = ""
   end
   def start_facebook_session_and_populate
     populate_user_info
     controller.facebook_session = @session
     controller.params = {}
     controller.params[:user] = ""
     
   end
end