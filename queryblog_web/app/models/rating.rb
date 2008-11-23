class Rating
  include DataMapper::Resource
  
  property :id, Serial

  property :rating, Float

  belongs_to :rating_type, :class_name => 'RatingType'
end
