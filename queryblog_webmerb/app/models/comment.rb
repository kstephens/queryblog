class Comment
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by_user_id ], :class_name => 'User'
  property :created_on, Time

  belongs_to :predecessor_query, :child_key => [ :predecessor_query_id ], :class_name => 'Query'
  
  property :title, String
  property :text, Text

  has_tags_on :tags

  before :save do
    AuthBuilder.before_save self
  end

end
