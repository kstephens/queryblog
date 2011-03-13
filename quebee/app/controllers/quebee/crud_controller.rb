module Quebee
  module CrudController
    class Error < ::Exception
      class NotAuthorized < self; end
      class NotFound < self; end
    end

    def self.included target
      super
      # $stderr.puts "#{self} target = #{target} #{target.ancestors.inspect}"
      target.instance_eval do
        before_filter :authorization_check!
        before_filter :index_model!, :only => [ :index ]
        before_filter :find_model!, :only => [ :show, :edit, :update, :destroy ]
        before_filter :new_model!, :only => [ :new ]
        around_filter :destroy_model!, :only => [ :destroy ]
      end
    end

    def authorization_check!
      raise Auth::Error unless current_user_can?
      self
    end

    def index_model_options
      [ ]
    end

    def index_model!
      self.model_instances = model_class.all(*index_model_options)
      self
    end

    def find_model!
      x = model_class.find(params[:id])
      raise NotFound unless x
      self.model_instance = x
      self
    end

    def new_model!
      self.model_instance = model_class.new(params[model_name])
      self
    end

    def update_model!
      if self.model_instance.update_attributes(params[model_name])
        return if :redirect == block_given? && yield(:before)
        if self.model_instance.save!
          return if :redirect == block_given? && yield(:after) 
          redirect_to :action => :edit
        else
          flash[:message] = "Could not update #{model_class_name}"
          (flash[:errors] ||= { })[model_name] = model_instance.errors
          return if :redirect == block_given? && yield(:error)
          redirect_to :action => :edit
        end
      end
    end

    def create_model!
      new_model!
      return if :redirect == block_given? && yield(:before)
      if self.model_instance.save!
        return if :redirect == block_given? && yield(:after) 
        redirect_to :action => :show, :id => self.model_instance
      else
        flash[:message] = "Could not create #{model_class_name}"
        (flash[:errors] ||= { })[model_name] = model_instance.errors
        return if :redirect == block_given? && yield(:error)
        render :action => :new
      end
    end

    def destroy_model!
      if self.model_instance.destroy
        redirect_to :action => :index
      else
        flash[:message] = "Could not destroy #{model_class_name}"
        (flash[:errors] ||= { })[model_name] = model_instance.errors
        redirect_to :action => :index
      end
    end

    ##################################################################

    def model_class_name
      @model_class_name ||=
        self.class.name.sub(/Controller\Z/, '').singularize
    end

    def model_class
      @model_class ||= 
        model_class_name.constantize
    end

    def model_name
      @model_name ||=
        model_class_name.demodulize.underscore.to_sym
    end

    def model_ivar_name
      @model_ivar_name ||=
        "@#{model_name}".freeze
    end

    def model_instance
      instance_variable_get(model_ivar_name)
    end

    def model_instance= x
      instance_variable_set(model_ivar_name, x)
    end

    def model_instances
      instance_variable_get(model_ivar_name.pluralize)
    end

    def model_instances= x
      instance_variable_set(model_ivar_name.pluralize, x)
    end

  end
end
