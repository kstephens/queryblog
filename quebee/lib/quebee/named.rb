module Quebee
  module Named
    def self.included target
      super
      # target.extend(ClassMethods)
      target.instance_eval do
        property :name, target.const_get('String'), :required => true
        property :description, target.const_get('Text'), :required => true

        before :valid? do
          self.description || self.name
          self
        end
      end
    end

    module ClassMethods
    end
  end
end

