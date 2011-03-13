class Login < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    render
  end

  def logout
    session.user = nil
    redirect '/'
  end
end
