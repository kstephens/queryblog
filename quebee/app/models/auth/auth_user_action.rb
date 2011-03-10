module Auth

# Maps users and their immediately associated actions.
#
# These mappings take priority over any actions associated by a user's roles.
class AuthUserAction
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by ], :class_name => 'AuthUser'
  property :created_on, Time

  belongs_to :user,   :child_key => [ :user_id ], :class_name => 'AuthUser'
  belongs_to :action, :child_key => [ :action_id ], :class_name => 'AuthAction'

  property :enabled, Boolean
  property :expires_on, Time

  property :allow, Boolean

  before :save do
    AuthBuilder.before_save self
  end
end


require 'auth/auth_user'
class AuthUser
  has 0 .. n, :user_actions, :class_name => 'AuthUserAction'
end

end
