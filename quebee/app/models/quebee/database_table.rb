module Quebee

class DatabaseTable
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  has 1 .. n, :database_columns, :model => 'DatabaseColumn'
end

end
