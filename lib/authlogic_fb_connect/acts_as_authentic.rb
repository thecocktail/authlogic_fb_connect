module AuthlogicFbConnect

  module ActsAsAuthentic
    
    def self.included(klass)
      klass.class_eval do
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Methods

       def self.included(klass)
        klass.class_eval do
         # attr_reader :facebook_id
          validate :validate_fb_connect
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_fb_connect?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_fb_connect?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_fb_connect?)
        end
      end
  
      def save(perform_validation = true,&block)
        if !perform_validation  || !authenticate_with_fb_connect? ||(authenticate_with_fb_connect? && authenticate_with_fb_connect)
          result = super
          yield(result) if block_given?
          result
       else
         false
       end
      end
    
      private
    
      def authenticate_with_fb_connect
         @fb_connect_errors = nil
         self.facebook_id = session_class.controller.facebook_session.user.id
         if self.respond_to?(:avatar)
           if session_class.controller.params[:user][:avatar].blank?
             avatar = get_avatar(self.facebook_id)
           else
             avatar = session_class.controller.params[:user][:avatar]
           end
           self.avatar = avatar
         end
         return true
      end
      
      def authenticate_with_fb_connect?
        !session_class.controller.blank? && !session_class.controller.facebook_session.blank? && !session_class.controller.facebook_session.expired? && no_password_provided?  
      end
      
      def validate_password_with_fb_connect?
        !authenticate_with_fb_connect? && require_password?
      end
      
      def validate_email_with_fb_connect?
        !authenticate_with_fb_connect?
      end
      
      def validate_fb_connect
        errors.add_to_base("Ha ocurrido el siguiente error: Session de Facebook no encontrada") if @fb_connect_errors
      end
      
      def no_password_provided?
        session_class.controller.params[:user].blank? || session_class.controller.params[:user][:password].blank? 
      end
      
      def get_avatar(filename)
        im = open(session_class.controller.facebook_session.user.pic_big)
        unless im.blank?
          f = File.new("#{RAILS_ROOT}/tmp/#{filename}.jpg","w+") 
          f.write(im.read)
          return f
        end
      end
    end
  end
end