module Quebee

# A user rating of a object.
class Rating
  include DataMapper::Resource
  
  property :id, Serial

  property :rating, Float

  # belongs_to :target, :class_name => 'RatingTarget'

  belongs_to :user, :class_name => 'User'

  belongs_to :rating_type, :class_name => 'RatingType'
end

end
