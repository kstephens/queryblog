module Quebee
  module Named
    def self.included target
      super
      # target.extend(ClassMethods)
      target.instance_eval do
        property :name, target.const_get('String')
        property :description, target.const_get('Text')
      end
    end

    module ClassMethods
    end
  end
end

