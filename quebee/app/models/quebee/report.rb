module Quebee

class Report
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :query, :child_key => [ :predecessor_query_id ], :model => 'Query'

  belongs_to :source_database, :child_key => [ :source_database_id ], :model => 'Database'
  belongs_to :result_database, :child_key => [ :result_database_id ], :model => 'Database'

  property :name, String
  property :description, Text

  has 0 .. n, :report_executions, :model => 'ReportExecution', :order => [ :query_executions_index ]
  property :report_executions_count, Integer

  has_tags_on :tags

  property :result_is_sensitive, Boolean
 
  before :save do
    self.result_is_sensitive ||= false
  end


  def execute!(options = { })
  end


  def self.initialize!
  end

end

end

