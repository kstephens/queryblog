module Auth
module Application
  def authenticated_user
    user = session.user
    if user && ! user.enable_login
      user = session.user = nil
    end
    user
  end
  protected :authenticated_user


  def current_user
    @current_user ||=
      authenticated_user ||
      AuthBuilder.guest_user
  end
  protected :current_user


  before :initialize_created_by!

  def initialize_created_by!
    AuthBuilder.created_by = current_user
    AuthBuilder.created_on = Time.now
  end
  protected :initialize_created_by!


  def authorizer
    @authorizer ||=
      Authorizer.new(:user => current_user)
  end
  protected :authorizer


  def authenticated_user_can? action = nil
    action ||= uri_action
    authenticated_user && 
      authorizer.user_can_do?(*action.split('/'))
  end
  protected :authenticated_user_can?


  def current_user_can_show? object, attr = nil
    action = (url(object.class.name.downcase / 'show', object) / attr).sub(/\A\//, '')

    result = 
      current_user &&
      authorizer.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can_show?(#{(current_user && current_user.login).inspect}, #{object.inspect} #{action.inspect}) => #{result.inspect}"

    result
  end
  protected :current_user_can_show?


  def current_user_can_edit? object, attr = nil
    action = (url(object.class.name.downcase / 'edit', object) / attr).sub(/\A\//, '')

    result = 
      current_user &&
      authorizer.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can_edit?(#{(current_user && current_user.login).inspect}, #{object.inspect} #{action.inspect}) => #{result.inspect}"

    result
  end
  protected :current_user_can_edit?


  def current_user_can? action = nil
    action ||= uri_action
    result = 
      current_user &&
      authorizer.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can?(#{(current_user && current_user.login).inspect}, #{action.inspect}) => #{result.inspect}"

    result
  end
  protected :current_user_can?


  # Converts the uri_path
  # into a auth_action.
  #
  #   users/1/edit => users/edit/1
  #   users/1 => users/show/1
  #   users => users/index
  #   users/1/delete => users/delete/1
  #
  def uri_action
    @uri_action ||=
      case uri_path
      when %r|^([^/]+)$|
        "#{$1.singularize}/index"
      when %r|^([^/]+)/(\d+)$|
        "#{$1.singularize}/show/#{$2}"
      when %r|^([^/]+)/(\d+)/([^/]+)$|
        "#{$1.singularize}/#{$3}/#{$2}"
      else
        x = uri_path.split('/')
        x[0] = x[0].singularize
        x.join('/')
      end.freeze
  end
  protected :uri_action


  def uri_path
    @uri_path ||=
      URI.parse(request.uri).path.sub(/\A\//, '').sub(/\/\Z/, '')
  end
  protected :uri_path

end

end
