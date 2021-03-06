module Auth

# Maps users and their immediately associated actions.
#
# These mappings take priority over any actions associated by a user's roles.
class AuthUserAction
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :user,   :child_key => [ :user_id ], :model => 'Auth::AuthUser'
  belongs_to :action, :child_key => [ :action_id ], :model => 'Auth::AuthAction'

  property :enabled, Boolean
  property :expires_on, Time

  property :allow, Boolean
end


require 'auth/auth_user'
class AuthUser
  has 0 .. n, :user_actions, :model => 'Auth::AuthUserAction'
end

end
