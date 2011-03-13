module Auth

class AuthUserRole
  include DataMapper::Resource
  
  property :id, Serial

  property :created_on, Time
  belongs_to :created_by, :child_key => [ :created_by ], :model => 'Auth::AuthUser'

  belongs_to :user, :child_key => [ :user_id ], :model => 'Auth::AuthUser'
  belongs_to :role, :child_key => [ :role_id ], :model => 'Auth::AuthRole'

  property :enabled, Boolean
  property :expires_on, Time

  before :save do
    AuthBuilder.before_save self
  end
end

require 'auth/auth_user'
class AuthUser
  has 0 .. n, :user_actions, :child_key => [ :user_id ], :model => 'Auth::AuthUserAction'
  has 0 .. n, :user_roles,   :child_key => [ :role_id ], :model => 'Auth::AuthUserRole'

  def roles
    user_roles.select{|x| x.enabled}.map{|x| x.role}.select{|x| x.enabled}
  end

  def actions allow = true
    (
     user_actions.select{|x| x.enabled || x.allow == allow}.map{|x| x.action} +
     roles.map{|x| x.role_actions}.select{|x| x.allow == allow}.map{|x| x.action }
     ).flatten
  end
end

end
