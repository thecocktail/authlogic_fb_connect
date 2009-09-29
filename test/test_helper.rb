require 'test/unit'
require 'rubygems'
require 'flexmock/test_unit'
require 'mocha'
require "ruby-debug"
require "active_record"
require 'facebooker'
require 'facebooker/rails/test_helpers'
require 'facebooker/rails/controller'
require 'action_controller'

ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table "users", :force => true do |t|
     t.string   "name",                 :limit => 120, :default => "",    :null => false
     t.string   "nicename",             :limit => 120, :default => "",    :null => false
     t.string   "email"
     t.string   "country",              :limit => 80,  :default => "",    :null => false
     t.integer  "province_id",          :limit => 4
     t.string   "zipcode"
     t.string   "avatar_file_name"
     t.string   "avatar_mime_type",     :limit => 64
     t.integer  "login_count",          :limit => 4,   :default => 0,     :null => false
     t.string   "crypted_password"
     t.string   "password_salt"
     t.string   "persistence_token",                   :default => "",    :null => false
     t.string   "perishable_token",                    :default => "",    :null => false
     t.datetime "confirmed_at"
     t.boolean  "admin",                               :default => false, :null => false
     t.datetime "created_at"
     t.datetime "updated_at"
     t.string   "facebook_id"
     t.string   "facebook_session_key"
   end
end

require "active_record/fixtures"
require File.dirname(__FILE__) + "/../../authlogic/lib/authlogic"
require File.dirname(__FILE__) + "/../../authlogic/lib/authlogic/test_case"
require File.dirname(__FILE__) + '/../lib/authlogic_fb_connect'  
require File.dirname(__FILE__) + '/libs/user'
require File.dirname(__FILE__) + '/libs/user_session'



class FBConnectController < Authlogic::TestCase::MockController
  def facebook_session
    @facebook_session
  end
  def facebook_session=(value)
    @facebook_session = value
  end
  def params=(value)
    @params = value
  end
end


class ActiveSupport::TestCase
  include Authlogic::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = false
  fixtures :all
  
  setup :activate_authlogic
  
  private
  
  def activate_authlogic
    Authlogic::Session::Base.controller = controller
  end
        
  def controller
    @controller ||= FBConnectController.new
  end
 
  
  def establish_session(session = @session)
    mock = flexmock(Net::HTTP).should_receive(:post_form).and_return(example_auth_token_xml).once.ordered(:posts)
    mock.should_receive(:post_form).and_return(example_get_session_xml).once.ordered(:posts)
    session.secure!    
    mock
  end
  
  def populate_user_info
    mock_http = establish_session
    mock_http.should_receive(:post_form).and_return(example_user_info_xml).once
    @session.user.populate
  end
  
  def example_auth_token_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <auth_createToken_response xmlns="http://api.facebook.com/1.0/" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        3e4a22bb2f5ed75114b0fc9995ea85f1
        </auth_createToken_response>    
    XML
  end
  
  def example_get_session_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <auth_getSession_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
      <session_key>5f34e11bfb97c762e439e6a5-8055</session_key>
      <uid>8055</uid>
      <expires>1453309298</expires>
      <secret>ohairoflamao12345</secret>
    </auth_getSession_response>    
    XML
  end  
  
  def example_user_info_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <users_getInfo_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd" list="true">
      <user>
        <uid>222333</uid>
        <about_me>This field perpetuates the glorification of the ego.  Also, it has a character limit.</about_me>
        <activities>Here: facebook, etc. There: Glee Club, a capella, teaching.</activities>
        <affiliations list="true">
          <affiliation>
            <nid>50453093</nid>
            <name>Facebook Developers</name>
            <type>work</type>
            <status/>
            <year/>
          </affiliation>
        </affiliations> 
        <birthday>November 3</birthday>
        <books>The Brothers K, GEB, Ken Wilber, Zen and the Art, Fitzgerald, The Emporer's New Mind, The Wonderful Story of Henry Sugar</books>
        <current_location>
          <city>Palo Alto</city>
          <state>CA</state>
          <country>United States</country>
          <zip>94303</zip>
        </current_location>
        <education_history list="true">
          <education_info>
            <name>Harvard</name>
            <year>2003</year>
            <concentrations list="true">
              <concentration>Applied Mathematics</concentration>
              <concentration>Computer Science</concentration>
            </concentrations>
            <degree>Masters</degree>
          </education_info>
        </education_history>
        <first_name>Dave</first_name>
         <hometown_location>
           <city>York</city>
           <state>PA</state>
           <country>United States</country>
           <zip>0</zip>
         </hometown_location>
         <hs_info>
           <hs1_name>Central York High School</hs1_name>
           <hs2_name/>
           <grad_year>1999</grad_year>
           <hs1_id>21846</hs1_id>
           <hs2_id>0</hs2_id>
         </hs_info>
         <is_app_user>1</is_app_user>
         <has_added_app>1</has_added_app>
         <interests>coffee, computers, the funny, architecture, code breaking,snowboarding, philosophy, soccer, talking to strangers</interests>
         <last_name>Fetterman</last_name>
         <meeting_for list="true">
           <seeking>Friendship</seeking>
         </meeting_for>
         <meeting_sex list="true">
           <sex>female</sex>
         </meeting_sex>
         <movies>Tommy Boy, Billy Madison, Fight Club, Dirty Work, Meet the Parents, My Blue Heaven, Office Space </movies>
         <music>New Found Glory, Daft Punk, Weezer, The Crystal Method, Rage, the KLF, Green Day, Live, Coldplay, Panic at the Disco, Family Force 5</music>
         <name>Dave Fetterman</name>
         <notes_count>0</notes_count>
         <pic>http://farm3.static.flickr.com/2200/buddyicons/26210361@N07.jpg?1232206977#26210361@N07</pic>
         <pic_big>http://farm3.static.flickr.com/2200/buddyicons/26210361@N07.jpg?1232206977#26210361@N07</pic_big>
         <pic_small>http://farm3.static.flickr.com/2200/buddyicons/26210361@N07.jpg?1232206977#26210361@N07</pic_small>
         <pic_square>http://farm3.static.flickr.com/2200/buddyicons/26210361@N07.jpg?1232206977#26210361@N07</pic_square>
         <political>Moderate</political>
         <profile_update_time>1170414620</profile_update_time>
         <quotes/>
         <relationship_status>In a Relationship</relationship_status>
         <religion/>
         <sex>male</sex>
         <significant_other_id xsi:nil="true"/>
         <status>
           <message>I rule</message>
           <time>0</time>
         </status>
         <timezone>-8</timezone>
         <tv>cf. Bob Trahan</tv>
         <wall_count>121</wall_count>
         <work_history list="true">
           <work_info>
             <location>
               <city>Palo Alto</city>
               <state>CA</state>
               <country>United States</country>
             </location>
             <company_name>Facebook</company_name>
             <position>Software Engineer</position>
             <description>Tech Lead, Facebook Platform</description>
             <start_date>2006-01</start_date>
             <end_date/>
            </work_info>
         </work_history>
       </user>
       <user>
         <uid>1240079</uid>
         <about_me>I am here.</about_me>
         <activities>Party.</activities>       
       </user>
    </users_getInfo_response>    
    XML
  end
end