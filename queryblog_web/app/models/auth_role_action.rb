class AuthRoleAction
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by ], :class_name => 'AuthUser'
  property :created_on, Time

  belongs_to :role,   :child_key => [ :role_id ],   :class_name => 'AuthRole'
  belongs_to :action, :child_key => [ :action_id ], :class_name => 'AuthAction'

  property :enabled, Boolean
  property :expires_on, Time

  property :allow, Boolean

  before :save do
    AuthBuilder.before_save self
  end
end


require 'auth_role'
class AuthRole
  has 0 .. n, :role_actions, :child_key => [ :role_id ], :class_name => 'AuthRoleAction'

  def actions
    role_actions.select{|x| x.enabled}.map{|x| x.action}
  end
end
