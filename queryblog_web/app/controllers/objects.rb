
# Provides a generic authenticated Ajax slot getter/setter controller.
class Objects < Application # AuthenticatedController
  provides :xml, :yaml, :js

 
  def get
    load_obj
    @value = @obj.send(@slot)
    display @value
  end


  def set
    load_obj
    @obj.send("#{@slot}=", new_value)
    @value = @obj.send(@slot)
    display @value
  end


  def load_obj
    $stderr.puts "params = #{params.inspect}"
    @clsname = params[:cls]
    @id = params[:id]
    @slot = params[:slot]
    @cls = Object.const_get(@clsname)
    @obj = @cls.get!(@id)
  end
  private :load_obj

  def authorizer
    @authorizer ||=
      AuthSolver.new(:user => current_user)
  end

end # Objects

