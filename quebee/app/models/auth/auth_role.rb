module Auth

# Represents authorization roles associated with users.
class AuthRole
  include DataMapper::Resource
  include Auth::Tracking

  property :name, String
  property :description, Text

  property :enabled, Boolean
  property :expires_on, Time
end

end
