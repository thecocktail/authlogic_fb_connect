require File.dirname(__FILE__) + '/test_helper.rb'

class SessionTest < ActiveSupport::TestCase

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
  
  def test_facebook_id_identifier
    session = UserSession.new
    assert session.respond_to?(:facebook_id)
  end
  
  def test_not_start_session_if_user_not_found
    start_facebook_session
    ses = UserSession.new(controller.params[:user_session])
    assert !ses.save
    assert ses.errors.on(:facebook_id)
  end
  
  def test_not_start_session_if_user_not_confirmed
    start_facebook_session
    @user = users(:yomismo)
    @user.update_attribute(:facebook_id, @session.user.id)
    ses = UserSession.new(controller.params[:user_session])
    assert !ses.save
    assert ses.errors.on(:base)
  end
  
  def test_start_session_account_confirmed
    start_facebook_session
    @user = users(:yomismo)
    @user.update_attribute(:facebook_id , @session.user.id)
    @user.update_attribute(:confirmed_at , Time.now)
    ses = UserSession.new(controller.params[:user_session])
    assert ses.save
    assert_equal ses.record.facebook_id.to_i, controller.facebook_session.user.id.to_i 
  end
  
  private
  
  def start_facebook_session
    establish_session(@session)
    controller.facebook_session = @session
    controller.params = {}
    controller.params[:user_session] = ""
  end
  
end