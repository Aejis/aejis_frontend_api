module FrontendApi
  ##
  # Model validator with resource-based validations.
  # Automatically applies validations (required attributes)
  # of a respectively named resource.
  #
  class ResourceValidator < ModelValidator
    class << self
      def inherited(subclass)
        subclass.validates_resource(subclass.resource_class)
      end

      def validates_resource(resource_class)
        resource_class.required_attributes.each do |attr, opts|
          validates :presence, attr, if: -> { !opts[:group] || @object[opts[:group]] }
        end
      end

      def resource(resource_class)
        @resource_class = resource_class
      end

      def resource_class
        @resource_class ||= FrontendApi::Resource.resource_for(name.gsub(/Validator\z/, ''))
      end
    end

    def initialize(object)
      super
      # set a named variable for convenience and to loosen dependency on superclass
      # e.g. @post for PostValidator
      if (name = self.class.name)
        instance_variable_set("@#{demodulize(name.gsub(/Validator\z/, '')).capitalize}", object)
      end
    end

  private

    def demodulize(path)
      path = path.to_s
      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end
  end
end
