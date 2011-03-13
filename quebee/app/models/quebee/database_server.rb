module Quebee

class DatabaseServer
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  belongs_to :admin, :model => 'User'

  belongs_to :database_group, :model => 'DatabaseGroup'

  has 0 .. n, :masters, :model => 'DatabaseServer'
  has 0 .. n, :slaves, :model => 'DatabaseServer'
end

end
