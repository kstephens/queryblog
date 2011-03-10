
class AuthBuilder

  # Returns the root user.
  def self.root_user
    @@root_user ||=
      AuthUser.first(:login => 'root')
  end

  # Returns the system user.
  def self.system_user
    @@system_user ||=
      AuthUser.first(:login => '*system*')
  end

  # Returns the guest user.
  def self.guest_user
    @@guest_user ||=
      AuthUser.first(:login => '*guest*')
  end


  def self.created_by
    x = Thread.current[:AuthUser_created_by]
    x = x.call if Proc === x
    x || authenticated_user
  end


  def self.created_by= x
    proc = Proc === x ? x : lambda {|| x }
    Thread.current[:AuthUser_created_by] = proc
    x
  end

  def self.created_on
    x = Thread.current[:AuthUser_created_on]
    x = x.call if Proc === x
    x || Time.now
  end

  def self.created_on= x
    proc = Proc === x ? x : lambda {|| x }
    Thread.current[:AuthUser_created_on] = proc
    x
  end

  def self.authenticated_user
    x = Thread.current[:AuthUser_authenticated_user]
    x = x.call if Proc === x
    x
  end


  def self.authenticated_user= x
    proc = Proc === x ? x : lambda {|| x }
    Thread.current[:AuthUser_authenticated_user] = proc
    x
  end


  def self.before_save obj
    obj.created_by = self.created_by if obj.created_by.nil?
    obj.created_on = self.created_on if obj.created_on.nil?
    obj.enabled    = true if obj.respond_to?(:enabled) && obj.enabled.nil?
  end


  attr_accessor :user
  attr_accessor :role
  attr_accessor :now

  def initialize opts = { }, &blk
    @user = opts[:user]
    @role = opts[:role]
    instance_eval &blk if block_given?
  end


  def user name = nil
    case name
    when nil
      user(@user || (raise ArgumentError))
    when AuthUser
      name
    when String
      AuthUser.first(:name => name)
    else
      raise ArgumentError
    end
  end


  def role name = nil
    role = 
      case name
    when nil
      role(@role || (raise ArgumentError))
    when AuthRole
      name
    when String
      x = AuthRole.first_or_create({ :name => name }, { :name => name })
      x.save! if x.new_record?
      x
    else
      raise ArgumentError
    end
    role
  end


  def action name
    case name
    when AuthAction, nil
      name
    when String
      x = AuthAction.first_or_create({ :name => name }, { :name => name })
      x.save! if x.new_record?
      x
    else
      raise ArgumentError
    end
  end


  def add_role user, role
    user = self.user(user)
    role = self.role(role)
    fargs = { :user_id => user.id, :role_id => role.id }
    args = { :user => user, :role => role }
    x = AuthUserRole.first_or_create(fargs, args)
    x.save! if x.new_record?
    role
  end


  def allow x, action, allow = true
    action = self.action(action)
    case x
    when AuthUser     
      fargs = { :user_id => x.id, :action_id => action.id, :allow => allow }
      args = { :user => x, :action => action, :allow => allow }
      x = AuthUserAction.first_or_create(fargs, args)
      x.save! if x.new_record?
      x
    when AuthRole
      fargs = { :role_id => x.id, :action_id => action.id, :allow => allow }
      args = { :role => x, :action => action, :allow => allow }
      x = AuthRoleAction.first_or_create(fargs, args)
      x.save! if x.new_record?
      x
    else
      raise ArgumentError
    end
  end


  def deny x, action 
    allow x, action, false
  end

end

