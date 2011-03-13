module Auth

# Performs authorization checks based on a user's roles and immediate actions.
class Authorizer
  attr_accessor :user
  attr_accessor :role
  attr_accessor :now


  def initialize opts
    @user = opts[:user]
    @role = opts[:role]
  end


  def _dump *args
    Marshal.dump([ @user.id, @role.id ])
  end


  def self._load str, *args
    @user, @role = Marshall.load(str)
    @user = AuthUser.get!(@user)
    @role = AuthRole.get!(@role)
  end


  def now
    @now ||=
      Time.now
  end


  def self.user_can_do? u, *a
    new(:user => u).user_can_do?(*a)
  end


  def self.cache_method method
    old_method = "without_cache_#{method}"
    new_method = "with_cache_#{method}"
    attr = "cache_for_#{method}".sub('?', 'Q').sub('!', 'E')
    expr = <<"END"
def #{new_method} *args
  ((@#{attr}_cache ||= { })[args.dup.freeze] ||= [ _log(:#{method}, args, #{old_method}(*args)) ]).first
end
alias :#{old_method} :#{method}
alias :#{method} :#{new_method}
END
    eval(expr)
  end


  def _log(meth, args, value)
    $stderr.puts "  #{meth} #{args.inspect} => #{value.inspect}"
    value
  end


  # resource/action/target/attribute
  #
  # users/list
  # users/new
  # users/show/1
  # users/show/1/email
  # users/edit/1
  # users/edit/1/login
  # users/delete/1
  #
  def user_can_do? resource, action, target = nil, attr = nil
    attr   = nil if attr == ''
    target = nil if target == ''

    if _user_can_do?('*') == true
      return true
    end

    target = ':self' if resource == 'user' && (target == user || target.to_s == user.id.to_s)

    $stderr.puts "  resource = #{resource.inspect}"
    $stderr.puts "  action   = #{action.inspect}"
    $stderr.puts "  target   = #{target.inspect}"
    $stderr.puts "  attr     = #{attr.inspect}"

    if _user_can_do_?(resource, action, target, attr) == false
      return false
    end

    case action
    when 'index'
      case
      when ! (x = user_can_do?(resource, 'list', target, attr)).nil?
        x
      else
        _user_can_do_?(resource, action, target, attr)
      end

    when 'create'
      case
      when ! (x = user_can_do?(resource, 'new', target, attr)).nil?
        x
      else
        _user_can_do_?(resource, action, target, attr)
      end

    when 'update'
      case
      when ! (x = user_can_do?(resource, 'edit', target, attr)).nil?
        x
      else
        _user_can_do_?(resource, action, target, attr)
      end

    when 'edit'
      case
      # If show is not allowed, don't allow edit.
      when user_can_do?(resource, 'show', target, attr) == false
        false
      else
        _user_can_do_?(resource, action, target, attr)
      end

    else
      _user_can_do_?(resource, action, target, attr)
    end
  end
  cache_method :user_can_do?


  def _user_can_do_? resource, action, target = nil, attr = nil
    case
    when _user_can_do_is?(false, resource, action, target, attr) == false
      false
    when _user_can_do_is?(true, resource, action, target, attr) == true
      true
    else
      nil
    end
  end
  cache_method :_user_can_do_?


  def _user_can_do_is? match, resource, action, target = nil, attr = nil
    case
    when target &&         _user_can_do?("#{resource}/#{action}/#{target}/*") == match
      match
    when target && attr && _user_can_do?("#{resource}/#{action}/#{target}/#{attr}") == match
      match
    when target &&         _user_can_do?("#{resource}/#{action}/#{target}/+") == match
      match
    when           attr && _user_can_do?("#{resource}/#{action}/*/#{attr}") == match
      match
    when target &&         _user_can_do?("#{resource}/#{action}/#{target}") == match
      match
    when           attr && _user_can_do?("#{resource}/#{action}/+/#{attr}") == match
      match
    when                   _user_can_do?("#{resource}/#{action}/*/*") == match
      match
    when                   _user_can_do?("#{resource}/#{action}/*/+") == match
      match
    when                   _user_can_do?("#{resource}/#{action}/*") == match
      match
    when                   _user_can_do?("#{resource}/#{action}/+") == match
      match
    when                   _user_can_do?("#{resource}/#{action}") == match
      match
    else
      nil
    end
  end
  cache_method :_user_can_do_is?


  def _user_can_do? action
    action = action.to_s.freeze

    user_actions.each do | action_id, action_name, allow |
      if action_name == action && allow == false
        return false
      end
    end
    
    user_actions.each do | action_id, action_name, allow |
      if action_name == action && allow == true
        return true
      end
    end
    
    return nil  
  end
  cache_method :_user_can_do?


  @@role_action_sql = <<-"END"
-- role_action_sql
SELECT
  a.id               AS action_id,
  a.name             AS action_name,
  ra.allow           AS allow
FROM 
  auth_auth_roles         AS r,
  auth_auth_role_actions  AS ra,
  auth_auth_actions       AS a 
WHERE
      (r.id = ?)
  AND (r.enabled)
  AND ((r.expires_on IS NULL) OR (r.expires_on > ?))
  AND (r.id = ra.role_id)
  AND (ra.enabled)
  AND ((ra.expires_on IS NULL) OR (ra.expires_on > ?))
  AND (ra.action_id = a.id)
  AND (a.enabled)
  AND ((a.expires_on IS NULL) OR (a.expires_on > ?))
END

  def role_actions
    @role_actions ||=
      do_sql(@@role_action_sql, role.id, now, now, now)
  end


  @@user_action_sql = <<-"END"
-- user_action_sql
SELECT
  a.id               AS action_id,
  a.name             AS action_name,
  ua.allow           AS allow
FROM 
  auth_auth_user_actions  AS ua,
  auth_auth_actions       AS a 
WHERE
      (ua.user_id = ?)
  AND (ua.enabled)
  AND ((ua.expires_on IS NULL) OR (ua.expires_on > ?))
  AND (ua.action_id = a.id)
  AND (a.enabled)
  AND ((a.expires_on IS NULL) OR (a.expires_on > ?))
END

  def user_actions
    @user_actions ||=
      do_sql(@@user_action_sql, user.id, now, now) +
      user_role_actions
  end


  @@user_role_action_sql = <<-"END"
-- user_role_action_sql
SELECT
  a.id               AS action_id,
  a.name             AS action_name,
  ra.allow           AS allow
FROM 
  auth_auth_user_roles    AS ur, 
  auth_auth_roles         AS r,
  auth_auth_role_actions  AS ra,
  auth_auth_actions       AS a 
WHERE
      (ur.user_id = ?)
  AND (ur.enabled)
  AND ((ur.expires_on IS NULL) OR (ur.expires_on > ?))
  AND (ur.role_id = r.id)
  AND (r.enabled)
  AND ((r.expires_on IS NULL) OR (r.expires_on > ?))
  AND (r.id = ra.role_id)
  AND (ra.enabled)
  AND ((ra.expires_on IS NULL) OR (ra.expires_on > ?))
  AND (ra.action_id = a.id)
  AND (a.enabled)
  AND ((a.expires_on IS NULL) OR (a.expires_on > ?))
END

  def user_role_actions
    @user_role_actions ||=
      do_sql(@@user_role_action_sql, user.id, now, now, now, now)
  end


  def do_sql(sql, *params)
    result = SqlHelper.sql_query(nil, sql, *params)[2]
    # $stderr.puts "do_sql #{sql.split("\n").first} =>\n  #{result.map{|x| x.inspect}.join("\n  ")}"
    result
  end

end

end

