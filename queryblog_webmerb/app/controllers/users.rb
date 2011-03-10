require 'nickle_slots'

class Users < AuthenticatedController
  # provides :xml, :yaml, :js

  include NickleSlots::Helper

  def index
    raise AuthorizationError unless current_user_can?
    @users = User.all
    display @users
  end

  def inspect(id)
    # raise AuthorizationError unless current_user_can?
    @user = User.get(id)
    raise NotFound unless @user
    display @user
  end

  def show(id)
    raise AuthorizationError unless current_user_can?
    @user = User.get(id)
    raise NotFound unless @user
    display @user
  end

  def new
    raise AuthorizationError unless current_user_can?
    only_provides :html
    @user = User.new
    display @user
  end

  def edit(id)
    raise AuthorizationError unless current_user_can? 
    only_provides :html
    @user = User.get(id)
    raise NotFound unless @user
    display @user
  end

  def create(user)
    raise AuthorizationError unless current_user_can?
    @user = User.new(user)
    if @user.save
      redirect resource(@user), :message => {:notice => "User was successfully created"}
    else
      message[:error] = "User failed to be created"
      render :new
    end
  end

  def update(id, user)
    raise AuthorizationError unless current_user_can?
    @user = User.get(id)
    raise NotFound unless @user
    if @user.update_attributes(user)
       redirect resource(@user)
    else
      display @user, :edit
    end
  end

  def destroy(id)
    raise AuthorizationError unless current_user_can?
    @user = User.get(id)
    raise NotFound unless @user
    if @user.destroy
      redirect resource(:users)
    else
      raise InternalServerError
    end
  end

end # Users
