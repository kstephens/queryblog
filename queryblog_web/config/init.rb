# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'

gem 'merb-action-args'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml

dependency 'merb-haml'
dependency 'merb-assets'
dependency 'dm-tags'

Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '2d68bc5165a3745f6a8dbbd60b8fa4a4146ecf60'  # required for cookie session store
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 

Merb.add_mime_type(:csv, :to_csv, %w[text/csv])

Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end
