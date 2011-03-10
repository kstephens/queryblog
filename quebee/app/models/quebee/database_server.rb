module Quebee

class DatabaseServer
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  belongs_to :admin, :class_name => 'User'

  belongs_to :database_group, :class_name => 'DatabaseGroup'

  has 0 .. n, :masters, :class_name => 'DatabaseServer'
  has 0 .. n, :slaves, :class_name => 'DatabaseServer'
end

end
