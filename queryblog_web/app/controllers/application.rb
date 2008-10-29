class Application < Merb::Controller
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


  def auth_solver
    @auth_solver ||=
      AuthSolver.new(:user => current_user)
  end
  protected :auth_solver


  def authenticated_user_can? action = nil
    action ||= uri_action
    authenticated_user && 
      auth_solver.user_can_do?(*action.split('/'))
  end
  protected :authenticated_user_can?


  def current_user_can_show? object, attr = nil
    action = (url(object.class.name.downcase / 'show', object) / attr).sub(/\A\//, '')

    result = 
      current_user &&
      auth_solver.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can_show?(#{(current_user && current_user.login).inspect}, #{object.inspect} #{action.inspect}) => #{result.inspect}"

    result
  end
  protected :current_user_can_show?


  def current_user_can_edit? object, attr = nil
    action = (url(object.class.name.downcase / 'edit', object) / attr).sub(/\A\//, '')

    result = 
      current_user &&
      auth_solver.user_can_do?(*action.split('/'))

    $stderr.puts "current_user_can_edit?(#{(current_user && current_user.login).inspect}, #{object.inspect} #{action.inspect}) => #{result.inspect}"

    result
  end
  protected :current_user_can_edit?


  def current_user_can? action = nil
    action ||= uri_action
    result = 
      current_user &&
      auth_solver.user_can_do?(*action.split('/'))

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
      end
  end
  protected :uri_action


  def uri_path
    @uri_path ||=
      URI.parse(request.uri).path.sub(/\A\//, '').sub(/\/\Z/, '')
  end
  protected :uri_path

end


module Merb::Helpers::Form
  # HACKETY, HACK, HACK
  ENTITY_MAP = {
    '<' => '&lt;',
    '>' => '&gt;',
    '&' => '&amp;',
    "\n" => '&#x0A;',
  }

  def my_escape v
    v.to_s.gsub(/([<>&\n])/m) {| x | ENTITY_MAP[x] || x }
  end
    
  def my_text_area obj, name, slot, opts = { }
    opts[:name] ||= "#{name}[#{slot}]"
    str = '<textarea '
    opts.each do | k, v |
      str << "#{k}=\"#{h v.to_s}\" "
    end
    str << '>'
    v = obj.send(slot).to_s
    str << my_escape(v)
    str << '</textarea>'
  end

  def my_pre text, opts = { }
    str = '<pre '
    opts.each do | k, v |
      str << "#{k}=\"#{h v.to_s}\" "
    end
    str << '>'
    str << my_escape(text)
    str << '</pre>'
  end

  def my_synopsis text, max_size = 32
    text = text.to_s
    lines = text.split(/\n/).
      map{|x| x.gsub(/\A\s+|\s+\Z/, '') }.
      select{|x| ! x.empty?}

    if lines.size > 0 
      dots = true
    end
    line = lines.first
    if line.size >= max_size
      dots = true
    end
    if dots
      line = line[0, max_size - 4]
      line += ' ...'
    end
    line
  end

  
  def my_secs secs
    secs = secs.to_f
    time = Time.at(secs.to_i)
    case
    when secs < 1.second
      '%0.4f sec' % secs
    when secs < 60.second
      '%0.2f sec' % secs
    when secs < 1.hour
      time.strftime('%M:%S') + '.' + '%02d' % (secs * 100 % 100)
    when secs < 12.hour
      ('%dh ' % (secs / 1.hour)) + time.strftime('%M:%S')
    when secs < 24.hours
      '%0.1f hrs' % (secs / 1.hour)
    else
      '%0.1f days' % (secs / 1.day)
    end
  end

  def my_time time, now = Time.now
    time = time.to_time if Date === time
    time = Time.at(time.to_i) if Numeric === time

    diff = now - time
    if future = diff < 0
      diff = - diff
    end

    case
    when diff < 1.minute
      "#{'%0.1f' % diff} seconds #{future ? 'from now' : 'ago'}"
    when diff < 1.hour
      "#{(diff / 1.minute).to_i} minutes #{future ? 'from now' : 'ago'}"
    when diff < 24.hour && time.mday == now.mday
      time.strftime('%I:%M%p')
    when diff < 1.week
      (future ? 'next' : 'last') + time.strftime(' %A %I:%M%p')
    when diff < 1.month && time.month == now.month
      time.strftime('%m/%d')
    when diff < 1.year && time.year == now.year
      time.strftime('%m/%d')
    else
      time.strftime('%y/%m/%d')
    end
  end
end


