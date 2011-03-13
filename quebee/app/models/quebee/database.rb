module Quebee

class Database
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  belongs_to :database_type, :model => 'DatabaseType'
end

end
