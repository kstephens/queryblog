module Auth

class AuthBuilder

  attr_accessor :user
  attr_accessor :role
  attr_accessor :now

  def initialize opts = { }, &blk
    @user = opts[:user]
    @role = opts[:role]
    if block_given?
      save = DataMapper::Model.raise_on_save_failure
      begin
        DataMapper::Model.raise_on_save_failure = true
        instance_eval &blk
      rescue DataMapper::SaveFailureError => err
        @object = err.resource
        debugger
        $stderr.puts "#{err.inspect} #{err.backtrace * "\n"}\n#{@object && @object.errors.inspect}"
      ensure
        DataMapper::Model.raise_on_save_failure = save
      end
    end
  end

  def user name = nil
    case name
    when nil
      user(@user || (raise ArgumentError))
    when AuthUser
      name
    when String
      AuthUser.first(:login => name)
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
    when String, Symbol
      name = name.to_s
      # debugger
      x = AuthRole.first_or_create({ :name => name }, { :name => name })
      # x.save! if x.new?
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
    when Symbol, String
      name = name.to_s
      # debugger
      x = AuthAction.first_or_create({ :name => name }, { :name => name })
      # x.save! if x.new?
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
    # x.save! if x.new?
    role
  end


  def allow x, action, allow = true
    action = self.action(action)
    case x
    when AuthUser     
      fargs = { :user_id => x.id, :action_id => action.id, :allow => allow }
      args = { :user => x, :action => action, :allow => allow }
      x = AuthUserAction.first_or_create(fargs, args)
      # x.save! if x.new?
      x
    when AuthRole
      fargs = { :role_id => x.id, :action_id => action.id, :allow => allow }
      args = { :role => x, :action => action, :allow => allow }
      x = AuthRoleAction.first_or_create(fargs, args)
      # x.save! if x.new?
      x
    else
      raise ArgumentError
    end
  end


  def deny x, action 
    allow x, action, false
  end

end

end
