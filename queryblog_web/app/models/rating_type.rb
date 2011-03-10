
# Determines the rating type and its range.
class RatingType
  include DataMapper::Resource
  
  property :id, Serial

  property :name, String
  property :description, String

  property :min_rating, Float
  property :max_rating, Float

end
