module Quebee

class ReportTable
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by_user_id ], :model => 'User'
  property :created_on, Time

  belongs_to :report, :child_key => [ :predecessor_query_id ], :model => 'Query'
  belongs_to :result_table, :child_key => [ :predecessor_query_id ], :model => 'DatabaseTable'

  has_tags_on :tags

  property :result_is_sensitive, Boolean
 
  before :save do
    self.result_is_sensitive ||= false
    AuthBuilder.before_save self
  end


  def self.initialize!
  end

end

end
