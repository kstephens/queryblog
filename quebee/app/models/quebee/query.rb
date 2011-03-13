module Quebee

class Query
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  belongs_to :predecessor_query, :child_key => [ :predecessor_query_id ], :model => 'Query', :required => false
  
  property :code, Text, :required => true

  has 0 .. n, :query_executions, :model => 'QueryExecution', :order => [ :query_executions_index ]
  property :query_executions_count, Integer, :required => true

  has_tags_on :tags

  property :query_is_sensitive, Boolean, :required => true
  property :result_is_sensitive, Boolean, :required => true
 

  def query_lines
    @query_lines ||=
      query.split("\n")
  end


  before :valid? do
    self.query_is_sensitive ||= false
    self.result_is_sensitive ||= false
    self.query_executions_count ||= 0
    self
  end


  def execute!(options = { })
    options[:created_by] ||= 
      Auth::Tracking.created_by || 
      self.created_by
    options[:query] = self

    self.query_executions_count ||= 0
    self.query_executions_count += 1
    self.save!

    options[:query_executions_index] = self.query_executions_count
    options[:query_is_sensitive] = self.query_is_sensitive
    options[:result_is_sensitive] = self.result_is_sensitive

    qe = QueryExecution.new(options)
    qe.save!

    qe.execute!(:code => self.code)
    qe.save!

    qe
  end


  def self.initialize!
    # self.raise_on_save_failure = true
    Auth::Tracking.created_by = User.first(:login => 'user') or raise 'User not found'
    q = self.new(
                 :name => "List Users",
                 :description => "List users and auth_actions.",
                 :code => <<"END"
SELECT * FROM auth_auth_users;
;;
SELECT * FROM auth_auth_actions;
;;
END
                 )
    q.valid?
    q.save!
    debugger
    q
  end
end

end
