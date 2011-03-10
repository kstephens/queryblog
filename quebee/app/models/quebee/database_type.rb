module Quebee

class DatabaseType
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  property :adapter, String
end

end
