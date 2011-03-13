module Quebee

class QueryExecutionsController < ApplicationController
  include Auth::Application
  include CrudController
  respond_to :html, :xml, :json

  def index_model_options
    [ :order => [ :started_on.desc ] ]
  end

  def index
    @show_query = true
    respond_to do | format |
      format.html
      format.xml { render :xml => model_instances.to_xml }
      format.json { render :json => model_instances }
    end
  end

  def show
    respond_to do | format |
      format.html
      format.xml { render :xml => model_instance.to_xml }
      format.json { render :json => model_instance.to_json }
    end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

end # QueryExecutions

end
