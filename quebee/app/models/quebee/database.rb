module Quebee

class Database
  include DataMapper::Resource
  include Auth::Tracking

  property :id, Serial

  property :name, String
  property :description, Text

  belongs_to :database_type, :model => 'DatabaseType'
end

end
