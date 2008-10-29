AuthUser = User

class AuthUser

  def self.initialize!
    [ 'root', '*system*', '*guest*', 'user' ].map do | name |
      x = self.first_or_create({ :login => name }, 
                               { :login => name, 
                                 :password => name, 
                                 :enable_login => (name == 'root'),
                               }
                               )
      x.save! if x.new_record?
      x
    end

    AuthBuilder.new do 
      self.class.created_by = self.class.system_user
      self.class.created_on = Time.now
      
      superuser = add_role(self.class.root_user, 'superuser')

      allow superuser, '*'
      
      user_admin = add_role(self.class.root_user, 'user_admin')

      allow user_admin, 'user/new'
      allow user_admin, 'user/list'
      allow user_admin, 'user/show/*'
      allow user_admin, 'user/edit/*/login'
      allow user_admin, 'user/edit/*/password'
      allow user_admin, 'user/edit/*/enabled'
      
      guest_role = add_role(self.class.guest_user, '*guest*')
      
      allow guest_role, 'user/new'
      allow guest_role, 'user/list'
      allow guest_role, 'user/show/*'
      deny  guest_role, 'user/show/*/password'
      deny  guest_role, 'user/edit/*'

      allow guest_role, 'query/list'
      allow guest_role, 'query/show/*'

      user = AuthUser.first(:login => 'user')
      basic_role = add_role(user, 'basic')

      allow basic_role, 'user/new'
      allow basic_role, 'user/list'
      allow basic_role, 'user/show/*'
      allow basic_role, 'user/edit/:self'
      deny  basic_role, 'user/edit/:self/login'
      allow basic_role, 'user/edit/:self/+'

      allow basic_role, 'query/new'
      allow basic_role, 'query/list'
      allow basic_role, 'query/show/*'
      allow basic_role, 'query/execute/*'
    end
  end

end

