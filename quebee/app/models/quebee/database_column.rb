module Quebee

class DatabaseColumn
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :database_table, :class_name => 'DatabaseTable'

  property :name, String
  property :description, Text
  property :index, Integer

end

end
