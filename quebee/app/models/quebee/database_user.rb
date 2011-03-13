module Quebee

class DatabaseUser
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  belongs_to :user, :model => 'User'

  property :password, String
end

end
