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
        klass = demodulize(name.gsub(/Validator\z/, ''))
        instance_variable_set("@#{underscore(klass)}", object)
      end
    end

  private

    # Method from ActiveSupport::Inflector
    def demodulize(path)
      path = path.to_s
      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end

    # Method from ActiveSupport::Inflector
    def underscore(camel_cased_word)
      return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
      word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
      word.tr!("-".freeze, "_".freeze)
      word.downcase!
      word
    end
  end
end
