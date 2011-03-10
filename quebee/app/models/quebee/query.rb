module Quebee

class Query
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by_user_id ], :class_name => 'User'
  property :created_on, Time

  belongs_to :predecessor_query, :child_key => [ :predecessor_query_id ], :class_name => 'Query'
  
  property :name, String
  property :description, Text
  property :query, Text

  has 0 .. n, :query_executions, :class_name => 'QueryExecution', :order => [ :query_executions_index ]
  property :query_executions_count, Integer

  has_tags_on :tags

  property :query_is_sensitive, Boolean
  property :result_is_sensitive, Boolean
 

  def query_lines
    @query_lines ||=
      query.split("\n")
  end


  before :save do
    self.query_is_sensitive ||= false
    self.result_is_sensitive ||= false
    self.query_executions_count ||= 0
    AuthBuilder.before_save self
  end


  def execute!(options = { })
    options[:created_by] ||= 
      AuthBuilder.created_by || 
      self.created_by
    options[:query] = self

    self.query_executions_count += 1
    self.save!

    options[:query_executions_index] = self.query_executions_count
    options[:query_is_sensitive] = self.query_is_sensitive
    options[:result_is_sensitive] = self.result_is_sensitive

    qe = QueryExecution.new(options)
    qe.save!

    qe.execute!
    qe.save!

    qe
  end


  def self.initialize!
    AuthBuilder.created_by = User.first(:login => 'user')
    q = self.new :name => "List Users", :query => <<"END"
SELECT * FROM users;
;;
SELECT * FROM auth_actions;
;;
END
    q.save!
  end
end

end
