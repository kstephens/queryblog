module Quebee

class DatabaseGroup
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named
end

end
