
module Quebee

class User
  include DataMapper::Resource
  include SimplestAuth::Model
  
  property :id,     Serial
  property :login,  String
  property :email,  String

  property :created_on, Time
  property :enable_login, Boolean

  has_tags_on :tags

  before :save do 
    self.created_on ||= Time.now
    self.enable_login = true if self.enable_login.nil?
  end

  # SimplestAuth
  property :crypted_password, String, :length => 70
  authenticate_by :login
end


end
