module Quebee

class DatabaseType
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  property :adapter, String
end

end
