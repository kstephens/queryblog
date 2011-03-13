module Auth
  module Named
    def self.included target
      super
      target.extend(ClassMethods)
    end

    module ClassMethods
    end
  end    
end

