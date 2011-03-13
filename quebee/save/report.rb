module Quebee

class Report
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  belongs_to :query, :child_key => [ :predecessor_query_id ], :model => 'Query', :required => true

  belongs_to :source_database, :child_key => [ :source_database_id ], :model => 'Database'
  belongs_to :result_database, :child_key => [ :result_database_id ], :model => 'Database'

  has 0 .. n, :report_executions, :model => 'ReportExecution', :order => [ :report_executions_index ]
  property :report_executions_count, Integer, :required => true

  has_tags_on :tags

  property :result_is_sensitive, Boolean, :required => true
 
  before :save do
    self.result_is_sensitive ||= false
    self
  end


  def execute!(options = { })
  end


  def self.initialize!
  end

end

end

