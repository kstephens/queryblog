module Quebee

class QueriesController < ApplicationController
  include Auth::Application
  include CrudController
  respond_to :html, :xml, :json
  
  def index
    respond_to do | format |
      format.html
      format.xml { render :xml => model_instances.to_xml }
      format.json { render :json => model_instances }
    end
  end

  def show
    @query_executions = @query.query_executions(:order => [ :started_on.desc ], :limit => 10)
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

  def execute
    find_model!
    if qe = @query.execute!
      redirect_to eq
    else
      raise InternalServerError
    end
  end
end # Queries

end
