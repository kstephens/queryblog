module Quebee

class QueryBlog

  def self.auto_migrate!
    DataMapper.auto_migrate!
    Auth::AuthUser.initialize!
    Query.initialize!
  end
end

end
