module Auth
  EMPTY_String = ''.freeze
  EMPTY_Array = [].freeze
  EMPTY_Hash = {}.freeze
end

require 'auth/tracking'
require 'auth/auth_builder'
require 'auth/authorizer'
require 'auth/sql_helper'
require 'auth/application'

