module AuthlogicFbConnect
  
  module Session
    require 'open-uri'
    def self.included(klass)
      klass.class_eval do
        attr_reader :facebook_id
        validate :validate_fb_connect_error
        validate :validate_by_fb_connect, :if => :authenticating_with_fb_connect?
       end
    end
    
    def credentials=(value)
      super
      self.facebook_id = controller.facebook_session.user.id if !controller.facebook_session.nil?
    end
   
    def facebook_id=(value)
        @facebook_id = value.blank? ? nil : controller.facebook_session.user.id
        @facebook_error = nil
    end
    
    def save(&block)
      #block = nil if !controller.facebook_session.blank?
      super(&block)
    end
    
    private
    
    def authenticating_with_fb_connect?
     no_params_provided? &&  !controller.facebook_session.blank? 
    end
    
    def no_params_provided?
      controller.params[:user_session].blank? && controller.params[:confirmation].blank?
    end
    def validate_by_fb_connect
      if !controller.facebook_session
         errors.add_to_base("No hemos conseguido logearte con Facebook connect")
        return
      end
      #Search user by his facebook_id in DB
      self.attempted_record ||= klass.find_by_facebook_id(controller.facebook_session.user.id) 
     
      if !attempted_record
        errors.add(:facebook_id, "no encontrado entre nuestros usuarios. Por favor, registrate con tu cuenta de Facebook.")
        return
      elsif attempted_record.confirmed_at.blank? && !UserSession.disable_magic_states 
        errors.add_to_base("Por favor confirma tu cuenta de usuario, te hemos enviado un correo para que lo hagas.")
        return
      end
    end
    
    def validate_fb_connect_error
      errors.add(:facebook_id, @facebook_error.to_s) if @facebook_error
    end
    
    
  end
  
end