module Quebee

class DatabaseServer
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  belongs_to :admin, :model => 'User'

  belongs_to :database_group, :model => 'DatabaseGroup'

  has 0 .. n, :masters, :model => 'DatabaseServer'
  has 0 .. n, :slaves, :model => 'DatabaseServer'
end

end
