module Auth
  module Tracking
    def self.included target
      super
      target.instance_eval do
        include DataMapper::Resource

        unless target.properties.find { | p | p.name == :id }
          property :id, target.const_get('Serial') 
        end

        belongs_to :created_by, :child_key => [ :created_by_id ], :model => 'Auth::AuthUser'
        property :created_on, Time

        belongs_to :updated_by, :child_key => [ :updated_by_id ], :model => 'Auth::AuthUser', :required => false
        property :updated_on, Time, :required => false

        before :valid?, :auth_before_save!
        after :save, :auth_after_save!
        # before :save, :auth_before_save!
        # before :create, :auth_before_save!
      end
    end
    
    def auth_before_save!
      @auth_before_save_once ||=
        Auth::Tracking.before_save! self
    end

    def auth_after_save!
      @auth_before_save_once = nil
    end

    # Returns the root user.
    def self.root_user
      @@root_user ||=
        AuthUser.first(:login => 'root')
    end
    
    # Returns the system user.
    def self.system_user
      @@system_user ||=
        AuthUser.first(:login => '*system*')
    end
    
    # Returns the guest user.
    def self.guest_user
      @@guest_user ||=
        AuthUser.first(:login => '*guest*')
    end
    
    
    def self.created_by
      x = Thread.current[:'Auth::Tracking.created_by']
      x = x.call if Proc === x
      x || authenticated_user
    end
    
    
    def self.created_by= x
      proc = Proc === x ? x : lambda {|| x }
      Thread.current[:'Auth::Tracking.created_by'] = proc
      x
    end
    
    def self.created_on
      x = Thread.current[:'Auth::Tracking.created_on']
      x = x.call if Proc === x
      x || Time.now
    end
    
    def self.created_on= x
      proc = Proc === x ? x : lambda {|| x }
      Thread.current[:'Auth::Tracking.created_on'] = proc
      x
    end
    
    def self.authenticated_user
      x = Thread.current[:'Auth::Tracking.authenticated_user']
      x = x.call if Proc === x
      x
    end
    
    
    def self.authenticated_user= x
      proc = Proc === x ? x : lambda {|| x }
      Thread.current[:'Auth::Tracking.authenticated_user'] = proc
      x
    end
    
    
    def self.before_save! obj
      if obj.created_by.nil?
        obj.created_by = self.created_by
      else
        obj.updated_by = self.created_by
      end
      if obj.created_on.nil?
        obj.created_on = self.created_on
      else
        obj.updated_on = self.created_on
      end
      obj.enabled    = true if obj.respond_to?(:enabled) && obj.enabled.nil?
      obj
    end
    
  end    
end

