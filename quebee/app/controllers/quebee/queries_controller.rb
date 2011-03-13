module Quebee

class Queries < AuthenticatedController
  # provides :xml, :yaml, :js
  
  def index
    raise AuthorizationError unless current_user_can?
    @queries = Query.all
    display @queries
  end

  def show(id)
    raise AuthorizationError unless current_user_can?
    @query = Query.get(id)
    raise NotFound unless @query
    @query_executions = @query.query_executions(:order => [ :started_on.desc ], :limit => 10)
    display @query
  end

  def new
    raise AuthorizationError unless current_user_can?
    only_provides :html
    @query = Query.new
    display @query
  end

  def edit(id)
    raise AuthorizationError unless current_user_can?
    only_provides :html
    @query = Query.get(id)
    raise NotFound unless @query
    display @query
  end

  def create(query)
    raise AuthorizationError unless current_user_can?
    @query = Query.new(query)
    if @query.save
      redirect resource(@query), :message => {:notice => "Query was successfully created"}
    else
      message[:error] = "Query failed to be created"
      render :new
    end
  end

  def update(id, query)
    raise AuthorizationError unless current_user_can?
    @query = Query.get(id)
    raise NotFound unless @query
    # $stderr.puts "query = #{query.inspect}"
    # query['query'].gsub!(/^\s+/m, '')
    if @query.update_attributes(query)
      if params['submit'] =~ /Execute/i
        @query.execute!
        redirect url(:edit_query, @query)
      else
        redirect resource(@query)
      end
    else
      display @query, :edit
    end
  end

  def destroy(id)
    raise AuthorizationError unless current_user_can?
    @query = Query.get(id)
    raise NotFound unless @query
    if @query.destroy
      redirect resource(:queries)
    else
      raise InternalServerError
    end
  end

  def execute(id)
    raise AuthorizationError unless current_user_can?
    @query = Query.get(id)
    raise NotFound unless @query
    if qe = @query.execute!
      redirect url(:controller => :query_executions, :action => :show, :id => qe)
    else
      raise InternalServerError
    end
  end
end # Queries

end
