module Auth

# Maps roles and actions.
class AuthRoleAction
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by ], :model => 'Auth::AuthUser'
  property :created_on, Time

  belongs_to :role,   :child_key => [ :role_id ],   :model => 'Auth::AuthRole'
  belongs_to :action, :child_key => [ :action_id ], :model => 'Auth::AuthAction'

  property :enabled, Boolean
  property :expires_on, Time

  property :allow, Boolean

  before :save do
    AuthBuilder.before_save self
  end
end


require 'auth/auth_role'
class AuthRole
  has 0 .. n, :role_actions, :child_key => [ :role_id ], :model => 'Auth::AuthRoleAction'

  # Returns the enabled actions for this role.
  def actions
    role_actions.select{|x| x.enabled}.map{|x| x.action}
  end
end

end
