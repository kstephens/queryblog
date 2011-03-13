module Quebee

class ReportTable
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :report, :child_key => [ :report_id ], :model => 'Report'
  belongs_to :result_table, :child_key => [ :database_table_id ], :model => 'DatabaseTable'

  has_tags_on :tags

  property :result_is_sensitive, Boolean, :required => true
 
  before :valid? do
    self.result_is_sensitive ||= false
  end


  def self.initialize!
  end

end

end
