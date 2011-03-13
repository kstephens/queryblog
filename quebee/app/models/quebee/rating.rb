module Quebee

# A user rating of a object.
class Rating
  include DataMapper::Resource
  
  property :id, Serial

  property :rating, Float

  # belongs_to :target, :model => 'RatingTarget'

  belongs_to :user, :model => 'User'

  belongs_to :rating_type, :model => 'RatingType'
end

end
