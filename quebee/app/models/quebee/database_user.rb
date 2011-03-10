module Quebee

class DatabaseUser
  include DataMapper::Resource
  
  property :id, Serial

  property :created_on, Time
  belongs_to :user, :class_name => 'User'

  property :username, String
  property :password, String
end

end
