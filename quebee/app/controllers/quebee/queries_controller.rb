module Quebee

class QueriesController < ApplicationController
  include Auth::Application
  include CrudController
  
  def index
  end

  def show
    @query_executions = @query.query_executions(:order => [ :started_on.desc ], :limit => 10)
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
