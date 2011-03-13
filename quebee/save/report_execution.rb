module Quebee

class ReportExecution < QueryExecution
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :report, :model => 'Report'
  property :report_executions_index, Integer, :required => true

  # has_tags_on :tags

  before :valid? do
    self.report_executions_index ||= 0
    self
  end

end

end
