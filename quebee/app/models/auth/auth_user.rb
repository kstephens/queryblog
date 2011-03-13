module Auth

class AuthUser
  include DataMapper::Resource
  include SimplestAuth::Model

  property :id,     Serial
  property :login,  String
  property :email,  String

  property :created_on, Time
  property :enable_login, Boolean

  has_tags_on :tags

  before :save do 
    self.created_on ||= Time.now
    self.enable_login = true if self.enable_login.nil?
  end

  # SimplestAuth
  property :crypted_password, String, :length => 70
  authenticate_by :login

  ####################################################################

  def self.initialize!
    [ 'root', '*system*', '*guest*', 'user' ].map do | name |
      x = self.first_or_create({ :login => name }, 
                               { :login => name, 
                                 :password => name, 
                                 :enable_login => (name == 'root'),
                               }
                               )
      x.save! if x.new?
      x
    end

    AuthBuilder.new do 
      Tracking.created_by = Tracking.system_user
      Tracking.created_on = Time.now
      
      superuser = add_role(Tracking.root_user, 'superuser')

      allow superuser, '*'
      
      user_admin = add_role(Tracking.root_user, 'user_admin')

      allow user_admin, 'quebee/user'
      allow user_admin, 'quebee/user/new'
      allow user_admin, 'quebee/user/show/*'
      allow user_admin, 'quebee/user/edit/*/login'
      allow user_admin, 'quebee/user/edit/*/password'
      allow user_admin, 'quebee/user/edit/*/enabled'
      
      guest_role = add_role(Tracking.guest_user, '*guest*')
      
      allow guest_role, 'quebee/user'
      allow guest_role, 'quebee/user/new'
      allow guest_role, 'quebee/user/show/*'
      deny  guest_role, 'quebee/user/show/*/password'
      deny  guest_role, 'quebee/user/edit/*'

      allow guest_role, 'quebee/query'
      allow guest_role, 'quebee/query/show/*'

      allow guest_role, 'quebee/query_execution'
      allow guest_role, 'quebee/query_execution/show/*'

      user = AuthUser.first(:login => 'user')
      basic_role = add_role(user, 'basic')

      allow basic_role, 'quebee/user'
      allow basic_role, 'quebee/user/new'
      allow basic_role, 'quebee/user/show/*'
      allow basic_role, 'quebee/user/edit/:self'
      deny  basic_role, 'quebee/user/edit/:self/login'
      allow basic_role, 'quebee/user/edit/:self/+'

      allow basic_role, 'quebee/query'
      allow basic_role, 'quebee/query/new'
      allow basic_role, 'quebee/query/show/*'
      allow basic_role, 'quebee/query/execute/*'

      allow basic_role, 'quebee/query_execution'
      allow basic_role, 'quebee/query_execution/show/*'
    end
  end

end

end
