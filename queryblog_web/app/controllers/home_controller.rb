class HomeController < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    @top_queries    = Query.all(:order => [ :query_executions_count.desc ], :limit => 10)
    @new_queries    = Query.all(:order => [ :created_on.desc ],             :limit => 10)
    @recent_queries = QueryExecution.all(:order => [ :started_on.desc ],    :limit => 10)
    render
  end
  
end
