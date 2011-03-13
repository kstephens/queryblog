module Quebee

class DatabaseTable
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  has 1 .. n, :database_columns, :model => 'DatabaseColumn'
end

end
