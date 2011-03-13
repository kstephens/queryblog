module Quebee

class DatabaseSchema
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named
end

end
