module Auth

# Represents an action that can be applied to a object by an authorized user.
class AuthAction
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :created_by, :child_key => [ :created_by ], :model => 'Auth::AuthUser'
  property :created_on, Time

  property :name, String
  property :description, Text

  property :enabled, Boolean
  property :expires_on, Time
  
  before :save do
    AuthBuilder.before_save self
  end
end

end
