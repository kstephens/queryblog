module Quebee

class DatabaseColumn
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  belongs_to :database_table, :model => 'DatabaseTable'

  property :index, Integer

end

end
