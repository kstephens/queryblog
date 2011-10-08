module Quebee

class DatabaseGroup
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  has 0 .. n, :servers, :model => 'DatabaseServer'
end

end
