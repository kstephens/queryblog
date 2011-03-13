module Auth
module Application
  def self.included target
    super
    target.instance_eval do
      before_filter :initialize_created_by!
    end
  end

  def authenticated_user
    user = session[:user_id]
    user &&= User.find(user)
    if user && ! user.enable_login
      user = session[:user_id] = nil
    end
    user
  end


  def current_user
    @current_user ||=
      authenticated_user ||
      Auth::Tracking.guest_user
  end


  def initialize_created_by!
    Auth::Tracking.created_by = current_user
    Auth::Tracking.created_on = Time.now
  end


  def authorizer
    @authorizer ||=
      Auth::Authorizer.new(:user => current_user)
  end


  def authenticated_user_can? action = nil
    action ||= uri_action
    authenticated_user && 
      authorizer.user_can_do?(*action.split('/'))
  end


  def current_user_can_show? object, attr = nil
    action = "#{object.class.name.underscore}/show/#{object.id}/#{attr}".sub(/\A\//, '').sub(%r{//+}, '')

    result = 
      current_user &&
      authorizer.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can_show?(#{(current_user && current_user.login).inspect}, #{object.inspect} #{action.inspect}) => #{result.inspect}"

    result
  end


  def current_user_can_edit? object, attr = nil
    action = "#{object.class.name.underscore}/edit/#{object.id}/#{attr}".sub(/\A\//, '').sub(%r{//+}, '')

    result = 
      current_user &&
      authorizer.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can_edit?(#{(current_user && current_user.login).inspect}, #{object.inspect} #{action.inspect}) => #{result.inspect}"

    result
  end


  def current_user_can? action = nil
    action ||= uri_action
    result = 
      current_user &&
      authorizer.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can?(#{(current_user && current_user.login).inspect}, #{action.inspect}) => #{result.inspect}"

    result
  end


  # Converts the uri_path
  # into a auth_action.
  #
  #   users/1/edit => user/edit/1
  #   users/1 => user/show/1
  #   users => user/index
  #   users/1/delete => user/delete/1
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
        x.map!{|e| e.singularize}
        x.join('/')
      end.freeze
  end


  def uri_path
    @uri_path ||=
      URI.parse(request.url).path.
      sub(/\A\//, '').
      sub((x = params[:format]) ? ".#{x}" : '', '').
      sub(/\/\Z/, '')
  end

end

end
