module Quebee

class DatabaseGroup
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

end

end
