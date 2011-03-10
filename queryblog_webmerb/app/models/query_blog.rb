class QueryBlog

  def self.auto_migrate!
    DataMapper.auto_migrate!
    AuthUser.initialize!
    Query.initialize!
  end
end
