module Quebee

class ReportTable
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :report, :child_key => [ :predecessor_query_id ], :model => 'Query'
  belongs_to :result_table, :child_key => [ :predecessor_query_id ], :model => 'DatabaseTable'

  has_tags_on :tags

  property :result_is_sensitive, Boolean
 
  before :save do
    self.result_is_sensitive ||= false
  end


  def self.initialize!
  end

end

end
