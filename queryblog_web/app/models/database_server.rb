class DatabaseServer
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, Text

  belongs_to :admin, :class_name => 'User'
end

