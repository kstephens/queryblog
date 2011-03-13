module Quebee

class Storage

  def self.auto_migrate!
    DataMapper.auto_migrate!
    Auth::AuthUser.initialize!
    Quebee::Query.initialize!
  end
end

end
