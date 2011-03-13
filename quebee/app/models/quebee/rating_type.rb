module Quebee

# Determines the rating type and its range.
class RatingType
  include DataMapper::Resource
  include Auth::Tracking
  include Quebee::Named

  property :min_rating, Float
  property :max_rating, Float
end

end
