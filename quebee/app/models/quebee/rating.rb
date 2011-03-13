module Quebee

# A user rating of a object.
class Rating
  include DataMapper::Resource
  include Auth::Tracking

  property :rating, Float

  # belongs_to :target, :model => 'RatingTarget'

  belongs_to :user, :model => 'User'

  belongs_to :rating_type, :model => 'RatingType'
end

end
