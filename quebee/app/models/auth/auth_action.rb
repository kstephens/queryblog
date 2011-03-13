module Auth

# Represents an action that can be applied to a object by an authorized user.
class AuthAction
  include DataMapper::Resource
  include Auth::Tracking
  
  property :name, String
  property :description, Text

  property :enabled, Boolean
  property :expires_on, Time
end

end
