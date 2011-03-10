module Quebee

class Database
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  belongs_to :database_type, :class_name => 'DatabaseType'
end

end
