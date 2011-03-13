module Quebee

class ReportExecution < QueryExecution
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :report, :model => 'Report'
  property :report_executions_index, Integer

  before :save do
    self.query_results_count ||= 0
  end

end

end
