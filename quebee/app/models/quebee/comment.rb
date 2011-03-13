module Quebee

class Comment
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :predecessor_query, :child_key => [ :predecessor_query_id ], :model => 'Query'
  
  property :title, String
  property :text, Text

  has_tags_on :tags
end

end # module
