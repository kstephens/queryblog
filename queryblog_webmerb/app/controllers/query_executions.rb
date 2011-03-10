class QueryExecutions < Application
  # provides :xml, :yaml, :js

  def index
    @query_executions = QueryExecution.all(:order => [ :started_on.desc ])
    @show_query = true
    display @query_executions
  end

  def show(id)
    @query_execution = QueryExecution.get(id)
    raise NotFound unless @query_execution
    display @query_execution
  end

  def new
    only_provides :html
    @query_execution = QueryExecution.new
    display @query_execution
  end

  def edit(id)
    only_provides :html
    @query_execution = QueryExecution.get(id)
    raise NotFound unless @query_execution
    display @query_execution
  end

  def create(query_execution)
    @query_execution = QueryExecution.new(query_execution)
    if @query_execution.save
      redirect resource(@query_execution), :message => {:notice => "QueryExecution was successfully created"}
    else
      message[:error] = "QueryExecution failed to be created"
      render :new
    end
  end

  def update(id, query_execution)
    @query_execution = QueryExecution.get(id)
    raise NotFound unless @query_execution
    if @query_execution.update_attributes(query_execution)
       redirect resource(@query_execution)
    else
      display @query_execution, :edit
    end
  end

  def destroy(id)
    @query_execution = QueryExecution.get(id)
    raise NotFound unless @query_execution
    if @query_execution.destroy
      redirect resource(:query_executions)
    else
      raise InternalServerError
    end
  end

end # QueryExecutions
