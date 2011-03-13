class QueryResults < Application
  # provides :xml, :yaml, :js

  def index
    @query_results = QueryResult.all
    display @query_results
  end

  def show(id)
    @query_result = QueryResult.get(id)
    raise NotFound unless @query_result
    display @query_result
  end

  def new
    only_provides :html
    @query_result = QueryResult.new
    display @query_result
  end

  def edit(id)
    only_provides :html
    @query_result = QueryResult.get(id)
    raise NotFound unless @query_result
    display @query_result
  end

  def create(query_result)
    @query_result = QueryResult.new(query_result)
    if @query_result.save
      redirect resource(@query_result), :message => {:notice => "QueryResult was successfully created"}
    else
      message[:error] = "QueryResult failed to be created"
      render :new
    end
  end

  def update(id, query_result)
    @query_result = QueryResult.get(id)
    raise NotFound unless @query_result
    if @query_result.update_attributes(query_result)
       redirect resource(@query_result)
    else
      display @query_result, :edit
    end
  end

  def destroy(id)
    @query_result = QueryResult.get(id)
    raise NotFound unless @query_result
    if @query_result.destroy
      redirect resource(:query_results)
    else
      raise InternalServerError
    end
  end

end # QueryResults
