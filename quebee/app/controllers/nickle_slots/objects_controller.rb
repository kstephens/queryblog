
module NickleSlots

# Provides a generic authenticated Ajax slot getter/setter controller.
class Objects < ApplicationController # AuthenticatedController
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
    @cls = (@clsname.split('::').inject(Object){ | o, n | o.const_get(n) } rescue nil)
    raise ArgumentError, "Cannot locate #{@clsname.inspect}" unless @cls
    @obj = @cls.get!(@id)
  end
  private :load_obj


  def authorizer
    @authorizer ||=
      Authorizer.new(:user => current_user)
  end

end # ObjectsController

end
