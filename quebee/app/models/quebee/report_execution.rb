module Quebee

class ReportExecution < QueryExecution
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :report, :class_name => 'Report'
  property :report_executions_index, Integer

  before :save do
    AuthBuilder.before_save self
    self.query_results_count ||= 0
  end

end

end
