module Quebee

class DatabaseSchema
  include DataMapper::Resource
  
  property :id, Serial

end

end
