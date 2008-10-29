class AuthenticatedController < Application
  class AuthorizationError < ::Exception; end

  before :ensure_authenticated,
    :with => [
              # OpenID, 
              # FormPassword,
              :message => "Invalid Login",
             ]

end

